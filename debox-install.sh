#!/bin/bash

#must be run as root, because of debbootstrap
if [ "$(id -u)" != "0" ]; then
	echo “This script must be run as root” 1>&2
	exit 1
fi

ExitInstall() {
	adb shell busybox umount $mnt
	adb shell busybox rmdir $mnt
	if [ -d tmp ]; then
		rm -r tmp
	fi
	exit
}

ContinueYN() {
	echo "Do you want to continue ? [y/n]"
	read yesno
	if [ $yesno != "y" ]; then
		ExitInstall
	fi
}

if [ -f localVar.sh ]; then
	source ./localVar.sh
else
	exit
fi

export DEBOOTSTRAP_BIN="`whereis debootstrap | awk '{print $2}'`"
#export DEBOOTSTRAP_BIN="/dir/to/debootstrap/debootstrap"
#export DEBOOTSTRAP_DIR="/dir/to/debootstrap"

echo -e "
info: put you sdcard in your android
info: check if partition are okey\n"
for i in $d_uuid $sd_uuid $swp_uuid; do
	adb shell busybox blkid | grep $i 
done

if [ ! -x $DEBOOTSTRAP_BIN ]; then
	echo "Debootstrap is not installed" && exit
	exit
fi

echo -e "
info: please connect your android over usb
info: enable adb(root)"
adb wait-for-device
adb root

adb shell busybox mkdir -p $mnt
adb shell busybox mount -t ext4 UUID="$d_uuid" $mnt
echo "I: check if below 3 partitions show up"
adb shell busybox df -ha $sdcard $mnt $andsys_part 

echo "I: bootstrap $and_arch $debian_version $debian_server"
ContinueYN
mkdir tmp
$DEBOOTSTRAP_BIN --verbose --foreign --arch $and_arch $debian_version tmp/ $debian_server

echo "I: Configuring /etc/"
ContinueYN
echo "nameserver 8.8.8.8" > tmp/etc/resolv.conf
echo $hostName > tmp/etc/hostname
cp -v fstab tmp/etc/
cp -v sources.list tmp/etc/apt/

#echo "#! /system/bin/sh" > tmp/bin/chroot.sh
#cat localVar.sh chroot-init.sh >> tmp/bin/chroot.sh
#chmod 755 tmp/bin/chroot.sh

echo "I: copying $debian_version to $mnt"
ContinueYN
cd tmp
tar czf ../files.tar.gz *
cd ..
adb push files.tar.gz $mnt
adb shell busybox tar -xzv -f $mnt/files.tar.gz -C $mnt
adb shell rm $mnt/files.tar.gz 

echo "I: copying debox to Android System Partition"
ContinueYN
adb shell mount -o remount,rw -t yaffs2 $andsys_part /system
echo "#! /system/bin/sh" > debox
cat localVar.sh debox.sh >> debox
adb push debox /system/bin/
adb shell chmod 744 /system/bin/debox
adb shell mount -o remount,ro -t yaffs2 $andsys_part /system

echo "I: debian bootstrap second stage"
adb shell busybox chroot $mnt /bin/bash -c '
	export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH;
	/debootstrap/debootstrap --second-stage'

ExitInstall
echo "done"
