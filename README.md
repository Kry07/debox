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
 I made this Box-script to use a full Linux Terminal on my Android system.
// there are possibilitys to put the debian system in a .img file and mount it afterwards, 
// but i think this makes your system much more slower, especialsy if you want to work with your SD in Android.
// you can also set up vnc server and then run X-server over vnc-client on Android
 You have make you partition-table by your own!
 So you have to set up the the variables in localVar.sh.
 These Variables can be different in some Android devices
 the debox scribt is written with bash-syntax
 If you want Linux Terminal without root, gofor Kbox.
 You can go through debox-INSTALL and run all commands, if you understand them.
 Or run my debox-install.sh script, if you understand what it does.
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
  - sdcard mount check
  - sdcard mount -o android given options
  - use mount with uuid
  - make android system "/" access-abel in debox
  - run android programs out of the debbox
