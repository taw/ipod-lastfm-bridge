#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'digest/md5'
require 'time'

# Load configuration
require 'config'

# This is client id/version (rbi/0,3) for Ruby iPod-last.fm bridge,
# assigned by last.fm.
#
# If you want to reuse this code in a different project,
# or significantly change its functionality,
# please use different version number (rbi/<something else>),
# special id for test clients (tst/1.0),
# or get a new id from last.fm.
#
# Clients id make it easier for last.fm staff to track and
# fix potential bugs, and thus improve everyone's experience.
# Thanks
#
# Version number increased from rbi/0.1 to rbi/0.2
# when add_fake_songs_to_make_playcount_match option was added.
#
# Version number increased from rbi/0.2 to rbi/0.3
# when retrying was added.

client_id = 'rbi'
client_version = '0.3'

# Special id for test clients, uncomment if necessary
# client_id = 'tst'
# client_version = '1.0'

hs_url = "http://post.audioscrobbler.com/?hs=true&p=1.1&c=#{client_id}&v=#{client_version}&u=#{$user_name}"

STDIN.each{|stdin_line|
    artist, title, album, length, last_played = stdin_line.chomp.split(/ ; /)

    # Retry a few times in case of errors
    6.times do |i|
        if i == 5
            puts "Too many retries, exiting"
            exit
        elsif i != 0
            puts "Retrying #{i+1}" unless i == 0
        end
        
        begin
            response = Net::HTTP.get(URI.parse(hs_url))
        rescue
            puts "Network error, retrying"
            next
        end

        response =~ %r[\AUPTODATE\n([0-9A-Fa-f]{32})\n(\S+)\nINTERVAL (\d+)\n\Z] or raise "Protocol not understood: #{response}"

        challenge, post_url, interval = $1, $2, $3.to_i

        sleep interval

        md5_response = Digest::MD5.hexdigest(Digest::MD5.hexdigest($password) + challenge)

        data_form = {
            'u' => $user_name,
            's' => md5_response,
            'a[0]' => artist,
            't[0]' => title,
            'b[0]' => album,
            'm[0]' => '',
            'l[0]' => length,
            'i[0]' => Time.parse(last_played).gmtime.strftime("%Y-%m-%d %H:%M:%S")
        }

        begin
            res = Net::HTTP.post_form(URI.parse(post_url), data_form)
        rescue
            puts "Network error, retrying"
            next
        end

        if res.body =~ %r[\AOK\nINTERVAL (\d+)\n\Z]
            interval = $1.to_i
        elsif res.body =~ %r[\AFAILED Plugin bug: Not all request variables are set - no POST parameters.\nINTERVAL (\d+)\n\Z]
            interval = $1.to_i
            print "This is probably safe, retrying:\n", res.body.gsub(/^/, "  ")
            next
        else
            print "Failed:\n", res.body.gsub(/^/, "  ")
            exit
        end

        puts stdin_line  
        puts "Post successful"
        sleep interval
        break
    end
}
