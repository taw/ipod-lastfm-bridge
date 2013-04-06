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
    def ratings
	raw_data = play_counts_raw_data
	magic, hlen, entry_len, songs = raw_data.unpack("a4VVV")
	raise "Play Counts does not start with correct magic #{magic}" unless magic == "mhdp"
        raise "Size of Play Counts file seems to be incorrect" unless raw_data.size == songs*entry_len + hlen
        # This info was stored some other way (or not at all?) in older iPods
        raise "Play Counts entries too small to contain ratings (old iPod)" if entry_len < 16
	(0..songs-1).map{|i|
	    song_data = raw_data[hlen+i*entry_len, entry_len]
	    # Ignore the rest
	    play_count, last_played, audio_bookmark, rating = song_data.unpack("VVVV")
	    rating
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

songs   = ipod.songs
ratings = ipod.ratings
songs.zip(ratings).each{|song_data, rating|
    next if rating == 0
    song_data[:rating] = rating/20
    data = "#{song_data[:rating]} " +
           ("*" * song_data[:rating] + " " * (5-song_data[:rating])) +
           " ; " +
           "#{song_data[:artist]} ; " +
	   "#{song_data[:title]}"
    print data, "\n"
}
