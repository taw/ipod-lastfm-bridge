# Configuration file

# Data for your account on last.fm
# You need to change these
$user_name = 'myusername'
$password =  'mypassword'

# USB mounting under Linux is not consistent,
# there are many possible places where iPod can get mounted.
$ipod_paths = [
    "/media/sda2/iPod_Control/iTunes",
    "/media/sdb2/iPod_Control/iTunes",
    "/media/sdc2/iPod_Control/iTunes",
    "/media/sdd2/iPod_Control/iTunes",
    "/Volumes/TAW'S IPOD/iPod_Control/iTunes",
]

# In the ideal world, iPod would remember each time any song was played
# In the real world, it only remembers number of times it was played
# and the last time. So if a song was played many times, we have two options:
# 1. Just submit the last time.
#    The statistics will be totally wrong, but all times are correct.
#    [false]
# 2. Add fake song plays.
#    The statistics will be perfect, but some times are totally bogus.
#    [true]
# It depends on what you care more about. I think statistics are more
# important than timing, so I set it to true.
$add_fake_songs_to_make_playcount_match = false

# If you delete or clean your Last Played (iTunes does it automatically)
# on every sync, you don't need $last_old
#$last_old = "2006-12-08 08:06:14"
$last_old = nil

# Timezone correction, in hours
# If you have correct timezones on your computer and your iPod,
# it should not be necessary.
$ipod_timezone_shift = 0

# If you listen to non-music stuff (mostly audiobooks),
# you probably don't want to submit them to last.fm,
# but ipod doesn't mark them as non-music in any convenient way.
# Just add artists to this list:
$artists_ignore = [
    "David Allen",
    "Susan Jeffers",
    "Stephen R. Covey",
    "Chester L Karrass",
    "David DeAngelo",
    "Michael F. Roizen M.D.",
    "Salman Rushdie",
]
