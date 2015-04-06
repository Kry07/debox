#!/bin/bash

#must be run as root, because of debbootstrap
if [ "$(id -u)" != "0" ]; then
	echo “This script must be run as root” 1>&2
	exit 1
fi

if [ -f localVar.sh ]; then
	source ./localVar.sh
fi

echo -e "
info: put you sdcard in your android
info: check if partition are okey\n"
for i in $d_uuid $sd_uuid $swp_uuid; do
	adb shell busybox blkid | grep $i 
done

#DEBOOTSTRAP_BIN="`whereis debootstrap | awk '{print $2}'`"
export DEBOOTSTRAP_BIN="/home/matek/text/prog/shell/debox/other/debootstrap-1.0.67/debootstrap"
export DEBOOTSTRAP_DIR="/home/matek/text/prog/shell/debox/other/debootstrap-1.0.67"
if [ ! -x $DEBOOTSTRAP_BIN ]; then
	echo "Debootstrap is not installed" && exit
fi

echo -e "
info: please connect your android over usb
info: enable adb(root)"
adb wait-for-device
adb root

adb shell busybox mkdir -p $mnt
adb shell busybox mount -t ext4 UUID="$d_uuid" $mnt
echo "info: check if below 3 partitions show up"
adb shell busybox df -ha $sdcard $mnt $andsys_part 

echo "Do you want to continue ? [y/n]"
read yesno
if [ $yesno != "y" ]; then
	adb shell busybox umount $mnt
	adb shell busybox rmdir $mnt
	exit
fi

echo "do: bootstrap armel $debian_version $debian_server"
mkdir tmp
$DEBOOTSTRAP_BIN --verbose --foreign --arch armel $debian_version tmp $debian_server

echo "Do you want to continue ? [y/n]"
read yesno
if [ $yesno != "y" ]; then
	adb shell busybox umount $mnt
	adb shell busybox rmdir $mnt
	rm -r tmp
	exit
fi

echo "do: configurating /etc/"
echo "nameserver 8.8.8.8" > tmp/etc/resolv.conf
echo $hostName > tmp/etc/hostname
#cp fstab tmp/etc/
#rm tmp/etc/apt/sources.list
#cp -v sources.list tmp/etc/apt/sources.list
#echo "#! /system/bin/sh" > tmp/bin/chroot.sh
#cat localVar.sh chroot-init.sh >> tmp/bin/chroot.sh
#chmod 755 tmp/bin/chroot.sh

echo "cont [y/n]"
read yesno
if [ $yesno != "y" ]; then
	adb shell busybox umount $mnt
	adb shell busybox rmdir $mnt
	rm -r tmp
	exit
fi

echo "do: copy debian to $mnt"
cd tmp
tar czf ../files.tar.gz *
cd ..
adb push files.tar.gz $mnt
adb shell busybox tar -xzv -f $mnt/files.tar.gz -C $mnt
adb shell rm $mnt/files.tar.gz 

echo "do: configurating bootstrap"
adb shell busybox chroot $mnt /debootstrap/debootstrap --second-stage

echo "do: copying debox to Android System Partition"
adb shell mount -o remount,rw -t yaffs2 $andsys_part /system
echo "#! /system/bin/sh" > debox
cat localVar.sh debox.sh >> debox
adb push debox /system/bin/
adb shell chmod 744 /system/bin/debox
adb shell mount -o remount,ro -t yaffs2 $andsys_part /system

adb shell busybox umount $mnt
adb shell busybox rmdir $mnt

echo "done"
