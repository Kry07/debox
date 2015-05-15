debox-README
============

Debian chroot system on Android root

you need:
---------
 - Comuter with Linux (debian-based)
 - rooted Android device
 - busybox on your Android device
 - adb-tools

Comment:
-------
 I made this Box script, to use a full Debian Shell on my Android system.
 You have to make your partition-table by your own!
 You have to set up the the variables in localVar.sh.
 These Variables can be different in some Android devices
 The debox script is written with sh-syntax.
 Run debox-install.sh script, if you understand what it does.
 I would like to develope this script and appreciate help or ideas.

Features:
---------
 + you can run debox multiple times
 + first created session, umount debox on exit
 + you can login as root
 + you can login as $user
  - your sdcard will be mounted in /home/$user/
 + you can run commands from Adroid to Debox
  - debox top   # will run top in debox

Usage:
--------
 + debox start      # debox will be mounted
 + debox stop       # debox will be unmounted
 + debox root       # login debox as user root
 + debox startsd    # debox will be mounted, sd mounted as /home/user/
 + debox sd         # login debox as normal user

Disclaimer:
-----------
use this script at your own risk.

TODO:
  - adduser in debox-install.sh
  - make android system "/" access-able in debox
  - run android programs out of the debox
