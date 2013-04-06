#!/usr/bin/env ruby
# The binary formats are described here -> http://ipodlinux.org/ITunesDB

require 'iconv'

# Load configuration
require 'config'

class Ipod
    def play_counts_raw_data
        File.open("#{$ipod_path}/Play Counts").read
    end
    def play_counts_raw_data_write(raw_data)
        File.open("#{$ipod_path}/Play Counts", "w") {|fh|
          fh.print raw_data
        }
    end
    def clear_play_counts!
	raw_data = play_counts_raw_data
	magic, hlen, entry_len, songs = raw_data.unpack("a4VVV")
	raise "Play Counts does not start with correct magic #{magic}" unless magic == "mhdp"
        raise "Size of Play Counts file seems to be incorrect" unless raw_data.size == songs*entry_len + hlen
	(0..songs-1).each {|i|
	    raw_data[hlen+i*entry_len, 8] = [0, 0].pack("VV")
	}
        play_counts_raw_data_write(raw_data)
    end
end

# Where iPod got mounted in the end ?
$ipod_path = $ipod_paths.find{|d| File.exists? "#{d}/iTunesDB" }
raise "iTunesDB not found in any of: #{$ipod_paths.join ' '}" unless $ipod_path

ipod = Ipod.new

ipod.clear_play_counts!
