### Installation

debox depends on:
  - root
  - busybox

-----------------------------------
#### 1. Install adb and debootstrap

(Comands below works only for debian-based distributions.)

    sudo apt-get install debootstrap
    sudo apt-get install android-tools-adb

-----------------------------------
#### 2. Partitioning SD-Card

  - create 1. partition fat32 for your data.
  - create 2. partition swap                           # size: 2times bigger than your memory.
  - create 3. partition ext4 for the Debian system.     # my debox is about 300mb big(without x-server)

Tutorial for partitioning on [Android](http://androidandme.com/2009/08/news/how-to-manually-partition-your-sd-card-for-android-apps2sd/)

You can use also partitoning Programms like gparted... 

-----------------------------------
#### 3. Setting up Variables

Change all Variables in [localVar.sh](https://github.com/Kry07/debox/blob/master/localVar.sh). to your needs.
##### beware that you changed all the UUID variables, to your partitions.
You can find out the UUID with:

    sudo blkid /dev/mmcblk1p1 (example)
    sudo blkid -o list

Check if "source.list" is compatible with system version.

-----------------------------------
#### 4. setting up Debian


  Watch [debox-install.sh](https://github.com/Kry07/debox/blob/master/debox-install.sh) closely before you run it.
  Run it only, if you understand what it does.
  When the script runs it will ask you after each step, if it should continue.
  I made this for you to see where in the code you are.
  If somthing goes wrong wait till it ask, to close the Program cleanly.

-----------------------------------
#### 5. Run this in Android in debox


    apt-get install console-data
    dpkg-reconfigure tzdata
    dpkg-reconfigure locales
    passwd $user

##### Finish
