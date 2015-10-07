INSTALL
=============

#### !WARNING!

debox depnds on:
  - root
  - busybox

1. installing adb and debootstrap
----------------------

this below works only for ubuntu-based distributions.

    sudo apt-get install debootstrap
    sudo apt-get install android-tools-adb

2. partitioning SDcard
----------------------

  - create 1. partition fat32 for your data.
  - create 2. partition swap                           # size: 2times bigger than your memory.
  - create 3. partition ext4 for the Debian system.     # my debox is about 300mb big(without x-server)

Tutorial for partitioning on [Android](http://androidandme.com/2009/08/news/how-to-manually-partition-your-sd-card-for-android-apps2sd/)

You can use also partitoning Programms like gparted... 

3. setting up Variables
--------------------

Change all Variables in localVar.sh to your needs.
#### beware that you changed all the UUID variables, to your partitions.
You can find out the UUID with:

    sudo blkid /dev/sdb1 (example)
    sudo blkid -o list

Also the android systen partition could be different [/dev/block/mmcblk0p3]
Find it out with command:

    mount | grep system

Check if "source.list" is compatible with debian version.

4. setting up Debian
--------------------

Watch "debox-install.sh" closely before you run it.
Run it only, if you understand what it does.
When the script runs it will ask you after each step, if it should continioue.
I made this for you to see where in the code you are.
If somthing goes wrong wait till it ask, to close the programm cleanly.

5. run this in Android in debox
--------------------

apt-get install console-data
dpkg-reconfigure tzdata
dpkg-reconfigure locales
passwd $user

### Finish
