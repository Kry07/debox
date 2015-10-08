debox readme
------------

Debian chroot system on Android

#### You need:

 - Computer with Linux (debian-based)
 - rooted Android device
 - busybox on your Android device
 - adb-tools
 - debootstrap

#### Comment:

  I made this Box script, to use a full Debian Shell on my Android system.
  You have to make your partition-table by your own!
  You have to set up the the variables in [localVar.sh](https://github.com/Kry07/debox/blob/master/localVar.sh).
  The debox script is written with shell-syntax.
  I would like to develope this script and appreciate help or ideas.
##### See [INSTALL.md](https://github.com/Kry07/debox/blob/master/INSTALL.md) for installation.

#### Features:

 + you can run debox multiple times
 + first created session, umount debox on exit
 + you can login as root
 + you can login as user
  - your sdcard will be mounted in /home/user/sdcard/
 + you can run commands from Adroid to Debox
  - debox top   # will run top in debox

#### Usage:

 + debox start      # debox will be mounted
 + debox startsd    # debox and sdcard will be mounted
 + debox stop       # debox will be unmounted
 + debox root       # login debox as user root
 + debox sd         # login debox as normal user
 + debox [comand]   # run comand in debox

##### Use this script at your own risk !

##### Licensed under the [GNU General Public License](http://www.gnu.org/licenses/)
