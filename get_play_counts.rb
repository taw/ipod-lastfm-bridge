#!/usr/bin/env ruby
# The binary formats are described here -> http://ipodlinux.org/ITunesDB

require 'iconv'

# Load configuration
require 'config'

class String
    # Returns a list of [type, contents] chunks
    def parse_chunks
	chunks = []
        i = 0
	while true
	    break if i == size
	    chunk_type, header_size, total_size = self[i, 12].unpack("a4VV")
	    if chunk_type == "mhod" 
		chunks.push [chunk_type, self[i, total_size]]
		i += total_size
	    else
		chunks.push [chunk_type, self[i, header_size]]
		i += header_size
	    end
	end
	return chunks
    end
    def utf16_to_utf8
	Iconv.new("utf-8", "utf-16le").iconv(self)
    end
end

class Ipod
    def play_counts_raw_data
        File.open("#{$ipod_path}/Play Counts").read
    end
    def play_counts
	raw_data = play_counts_raw_data
	magic, hlen, entry_len, songs = raw_data.unpack("a4VVV")
	raise "Play Counts does not start with correct magic #{magic}" unless magic == "mhdp"
        raise "Size of Play Counts file seems to be incorrect" unless raw_data.size == songs*entry_len + hlen
	(0..songs-1).map {|i|
	    song_data = raw_data[hlen+i*entry_len, entry_len]
	    # Ignore the rest
	    play_count, last_played = song_data.unpack("VV")
	    if last_played == 0
		last_played = nil 
	    else
		last_played = Time.at(last_played - 2082848400 - 3600 * $ipod_timezone_shift)
	    end
	    [play_count, last_played]
	}
    end
    def songs_raw_data
        File.open("#{$ipod_path}/iTunesDB").read
    end
    def songs
	chunks = songs_raw_data.parse_chunks
	mhit = []
	chunks.each_with_index{|(chunk_type, chunk_contents), i|
	    next unless chunk_type == "mhit"
	    data = {}
	    chunk_type, header_size, total_size = chunk_contents.unpack("a4VV")

	    length_in_miliseconds = *chunk_contents[40,4].unpack("V")
	    data[:length] = length_in_miliseconds / 1000

	    children = []
	    j = i+1
	    children_size = header_size
	    while children_size < total_size
		children.push chunks[j]
		children_size += chunks[j][1].size
		j += 1
	    end
	    mhit.push [data, children]
	}
	return mhit.map{|data, children|
	    children = children.map{|chunk_type, chunk_contents|
		raise "mhit has children other than mhod" unless chunk_type == "mhod"
		magic, header_size, total_size, type = chunk_contents.unpack("a4VVV")
		# They have different format, apparently
		next unless type <= 14
		str = chunk_contents[40, total_size-40].utf16_to_utf8
		# Let's ignore everything except for these...
		data[:title]    = str if type == 1
		data[:location] = str.gsub(/:/, "/") if type == 2
		data[:album]    = str if type == 3
		data[:artist]   = str if type == 4
	    }
	    data
	}
    end
end

# Where iPod got mounted in the end ?
$ipod_path = $ipod_paths.find{|d| File.exists? "#{d}/iTunesDB" }
raise "iTunesDB not found in any of: #{$ipod_paths.join ' '}" unless $ipod_path

ipod = Ipod.new

songs       = ipod.songs
play_counts = ipod.play_counts

songs_to_submit = []
extra_songs = []

class TimeManager
    def initialize
        @intervals = []
    end
    def time_start
        @intervals.map{|start,len| start}.min
    end
    def time_end
        @intervals.map{|start,len| start+len}.max
    end
    def to_s
        "<#{time_start}...#{time_end}>"
    end
    # Handling of < vs <= is pretty much random
    def allocate_interval(new_len, must_start_before)
        @intervals.sort.reverse.each{|istart, ilen|
            new_start = istart - new_len
            next unless new_start < must_start_before
            next unless @intervals.all?{|jstart, jlen|
                jstart >= new_start + new_len || jstart + jlen <= new_start
            }
            add_interval(new_start, new_len)
            return new_start
        }
        # There must be some new_start if there's at least one interval.
        raise "No good #{new_len}s interval found"
    end
    def add_interval(start, len)
        @intervals << [start, len]
    end
end

tm = TimeManager.new

songs.each_with_index{|song_data, i|
    song_data[:play_count] = play_counts[i][0]
    song_data[:last_played] = play_counts[i][1] if play_counts[i][1]
    next if $artists_ignore.include? song_data[:artist]
    next if song_data[:play_count] == 0
    next if song_data[:length] < 30
    if $last_old
        next unless song_data[:last_played].strftime("%Y-%m-%d %H:%M:%S") > $last_old
    end
    data = "#{song_data[:artist]} ; " +
	   "#{song_data[:title]} ; " +
           "#{song_data[:album]} ; " +
	   "#{song_data[:length]}"
    songs_to_submit.push [song_data[:last_played], song_data[:length], data]
    
    tm.add_interval(song_data[:last_played], song_data[:length])
    
    (1...song_data[:play_count]).each{|i|
        extra_songs.push [i, data, song_data[:last_played], song_data[:length]]
    }
}

if $add_fake_songs_to_make_playcount_match
    extra_songs.sort.each{|i, data, real_last_played, len|
        played_at = tm.allocate_interval(len, real_last_played)
        songs_to_submit << [played_at, len, data]
    }
end

songs_to_submit.sort.each{|last_played, len, data|
    print "#{data} ; #{last_played.strftime('%Y-%m-%d %H:%M:%S')}\n"
}
