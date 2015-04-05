#!/bin/bash

if [ -f localVar.sh ]; then
	source ./localVar.sh
fi

echo -e "
info: put you sdcard in your android
info: check if partition are okey\n"
for i in $d_uuid $sd_uuid $swp_uuid; do
	adb shell busybox blkid | grep $i 
done

if [ ! -x "`whereis debootstrap | awk '{print $2}'`" ]; then
	echo "Debootstrap is not installed" && exit
fi

echo -e "
info: please connect your android over usb
info: enable adb(root)"

adb root
adb wait-for-device

echo "do: check partitions"
for i in $sd_part $swp_part $d_part $andsys_part; do
	suma=`adb shell "ls $i | md5sum"`
	suma="$(echo $suma | awk '{ print $1}')"
	sumb="$( echo $i | md5sum | awk '{ print $1}')"

	if [ $suma != $sumb ]; then
		echo -e "\n$i does not exist\nplease correct variables !"
		exit 1
	fi
done

adb shell busybox mkdir -p $mnt
adb shell busybox mount -t ext4 $d_part $mnt
adb shell busybox df -ha $sd_part $d_part $andsys_part

echo "do: bootstrap armel $debian_version $debian_server"
mkdir tmp
debootstrap --verbose --arch armel --foreign $debian_version tmp $debian_server

echo "do: configurating /etc/"
echo "nameserver 8.8.8.8" > tmp/etc/resolv.conf
echo $hostName > tmp/etc/hostname
cp fstab tmp/etc/
## dont work why? mybe now
cat sources.list >>! tmp/etc/apt/sources.list
echo "#! /system/bin/sh" > tmp/bin/chroot.sh
cat localVar.sh chroot-init.sh >> tmp/bin/chroot.sh

echo "cont [y/n]"
read yesno
if [ $yesno != "y" ]; then
	exit
fi

echo "do: copy debian to $d_part"
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

adb shell busybox umount $d_part
adb shell busybox rmdir $mnt

echo "done"
