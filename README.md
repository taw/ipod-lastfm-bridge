ipod-lastfm-bridge
==================

Command line program which extracts statistics from iPods and sends them to last.fm

Note
====

It's been a few years since my cat threw my iPod into water,
so I don't really know if this script still works, or not. 

Installation
============

This is a set of command line scripts for taking information on
what you played from an iPod, and sending it to last.fm.

Short instruction:
* Grab sources (from https://github.com/taw/ipod-lastfm-bridge)
* Unpack them. [If you're reading this file, you probably already got that far]

* Install Ruby, 1.8.3 or newer. The script doesn't work with 1.8.2.

* Edit config.rb
  You must input the following information:
  $user_name - your user name on last.fm
  $password  - your password on last.fm
  
  You may also want to edit:
  $ipod_paths - if your iPod is mounted somewhere nonstandard, fix it
  
  There are some more options, but you probably won't need them.
  Each one of them is commented in config.rb

* Mount your iPod. Depending on your configuration it might happen
  automatically when you connect it, or you might have to do it by hand.
  Typical paths where it is mounted are /media/sda2 /media/sdb2 etc.
  If it's a nonstandard place, add it to $ipod_paths in config.rb

* Try running:
  ./get_play_counts.rb

  It will read list of songs you played from iPod, and
  write it to stdandard output. This script will not send anything to last.fm.

  The format is simply one entry per line, so you can use any command
  line tool like grep to manage this list. 

  For example you can remove songs that you don't want to submit to last.fm
  (like audiobooks, or things that you don't want people to know that you listen to).
  The same effect can also be achieved by adding artists to $artists_ignore
  list in config.rb.
  
  If everything worked, go to the next step. If it didn't, check that:
  * Your iPod is mounted
  * The right path is in $ipod_paths in config.rb
  
* Send it to last.fm:
  ./get_play_counts.rb | ./as_sumbit.rb
  
  The script will inform you whether it succeeded or not.
  It aborts on the first error.
  
  If everything was well, your songs should be on your user page on last.fm.
  
  If you get error on the first song, check whether you have correct
  user name and password in config.rb and network connection works.

  Sometimes you won't get errors, but some songs are not on the list.
  This is because of last.fm filters.
  Common reasons:
  * Title is on the list of known bad titles (like Track 5)
  * Artist is on the list of known bad artists (like Unknown)
  * You're trying to submit the same entry multiple times
    (like running the script and then running it again, with the same songs)

* Congratulations

Cleaning up play counts
=======================

A few more things - the script does not clean up the list of played songs.
It's not a major problem, as if you try to resubmit the same songs,
last.fm is simply going to filter them out.

If you modify anything on your iPod (like upload a new song),
it will clean play counts automatically. Some iPod programs (like iTunes)
do that every time you sync your iPod too.

If you don't use any such program, and want to manage this by hand,
you can set $last_old in config.rb to the date of the last song
you don't want to care about.

Ratings
=======

There's one more script in the set, for getting ratings from iPod.
Just run it like this:
  ./get_ratings.rb
And it will print list of all rated (1-5 stars, those with 0 stars are considered
"not rated", and are not printed) songs on the standard out.

Unfortunately iPod cleans ratings together with play counts,
so it's not terribly useful.

iPod compatibility
==================

I only tested the script with metal-backed iPod nano, but other
users reported it running successfully with many other types of iPods.

Unfortunetaly according to one user report, iPod shuffle does not keep
track of play counts, so the script won't work with iPod shuffle.
I don't know if it applies to all or only some iPod shuffles.

Contact
=======

If you have any problems, questions, or praise ;-),
don't hesitate to mail me at Tomasz.Wegrzanowski@gmail.com
or ask at my blog http://t-a-w.blogspot.com/

Copyright
=========

All code was created by Tomasz Wegrzanowski.

It can be used, modified, distributed etc. for any purpose (including
commercial use), as long as attribution is preserved.

The full legal code follows.

Legalese
========

Copyright (c) 2006-2007 Tomasz Wegrzanowski <Tomasz.Wegrzanowski@gmail.com>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
