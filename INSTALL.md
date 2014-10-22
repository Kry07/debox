INSTALL
=============

#### !WARNING!

debox depnds on:
  - root
  - busybox

for using this scribt you need:
  - Computer with Linux
  - adb-tools
  - debootstrap

this below works only for ubuntu-based distributions.

    sudo apt-get install debootstrap
    sudo apt-get install android-tools-adb

1. partitioning SDcard
----------------------
  - create 1. partition fat32 for your data.
  - create 2. partition swap                           # size: 2times bigger than your memory.
  - create 3. partition ext4 for the Debian system.     # my debox is about 300mb big(without x-server)

Remember the path to your sdcard, exaple: /dev/sdb.

Tutorial for partitioning on [Android](http://androidandme.com/2009/08/news/how-to-manually-partition-your-sd-card-for-android-apps2sd/)

You can use also partitoning Programms like gparted... 

2. pushing Debian on your Android.
----------------------------------

Change the folowing command so it fit for you.
You can find it out with command "mount", if your sdcard is mounted. 

Example: could also be: "export dpart=/dev/sdc3"

    export dpart=/dev/sdb3

Mounting debian and downloading base system

    mount $dpart /mnt/
    debootstrap --verbose --arch armel --foreign squeeze /mnt http://ftp.de.debian.org/debian
    umount /mnt/

3. setting up Android
---------------------

#### Connect you Android device with usb
enable adb (is different on some android devices)

    adb wait-for-device
    adb shell
    su

#### Change the folowing variable so it fit for you
Hint, if it was before sdb3 then could be now mmcblk1p3.

    export dpart=/dev/block/mmcblk1p3   

variables:

    export mnt=/data/local/debian
    export PATH=$bin:/usr/bin:/usr/sbin:/bin:$PATH
    export TERM=linux
    export HOME=/root
    export USER=root
    
setup:

    busybox mkdir -p $mnt
    busybox mount -t ext4 $dpart $mnt

mount -t defines what type of partition, example: could be also "mount -t ext2 .. 

    busybox chroot $mnt /debootstrap/debootstrap --second-stage
    echo 'deb http://ftp.de.debian.org/debian squeeze main contrib non-free' > $mnt/etc/apt/sources.list
    echo localhost > $mnt/etc/hostname
    echo 'nameserver 4.2.2.2' > $mnt/etc/resolv.conf
    busybox mount -t devpts devpts $mnt/dev/pts
    busybox mount -t proc proc $mnt/proc
    busybox mount -t sysfs sysfs $mnt/sys
    busybox chroot $mnt /bin/bash

4. setting up Debian
--------------------

#### connect your Android to the Internet

updating and installing programms, you can add here all your favourite programms

variables:

    export DUSER=debox
    export HOME=/root
    export USER=root
    export LC_ALL=C

setup:

    rm -f /etc/mtab
    ln -s /proc/mounts /etc/mtab
    passwd root
    apt-get update
    apt-get install sudo locales network-manager openssh-client vim ssh openssh-server xfonts-base bash-completion
    adduser $DUSER
    usermod -a -G sudo $DUSER
    apt-get clean
    exit

5. back to Android and cleaning up
----------------------------------

Command to kill all remaining processes in debian

    MPUSED=`lsof | grep $mnt | awk '{print $2}' | sort -u`
    if [ -n "$MPUSED" ] ; then for i in $MPUSED; do busybox chroot $mnt /bin/bash -c "kill -s SIGKILL $i"; done; fi
    
Unmounting Debian, there should be no errors

    busybox umount $mnt/dev/pts
    busybox umount $mnt/proc
    busybox umount $mnt/sys
    busybox umount $mnt
    exit
    
##### Back on your Linux Computer and installation finished

6. copying debox to Android
---------------------------

#### Edit debox with your favourit editor!
##### beware that you changed all the variables in debox so they fit for your Android device !

Also here the system partition could be different [/dev/block/mmcblk0p3]

Find it out with command "mount | grep system"

    adb shell mount -o remount,rw -t yaffs2 /dev/block/mmcblk0p3 /system
    adb push debox /system/bin/
    adb shell chmod 744 /system/bin/debox
    adb shell mount -o remount,ro -t yaffs2 /dev/block/mmcblk0p3 /system

### Finish
try on your Android device to run 'debox root'
