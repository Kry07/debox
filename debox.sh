#! /system/bin/sh
export PATH=$bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
export dpart=/dev/block/mmcblk1p3
export dswap=/dev/block/mmcblk1p2
# export sdpart=/dev/block/mmcblk1p1
export sdpart=/dev/block/vold/179:33
# export sdcard=/mnt/external_sd
export sdcard=/storage/sdcard1
export mnt=/data/local/debian
export usr=icony
export usrMnt=$mnt/home/$usr/data
export TERM=linux
export HOME=/root
export USER=root

busyBmnt() {
	busybox mount -t $mtyp $mpart $mdir
	if [ $? -ne 0 ];then 
		echo "Unable to mount $mpart from type $mtyp to $mdir"
		exit
	fi
}

MntBox() {
	echo "starting debox... "
	busybox mkdir -p $mnt
	mtype="ext4" && mpart=$dpart && mdir=$mnt && busyBmnt
	#busybox mount -t ext4 $dpart $mnt
	busybox mount -t devpts devpts $mnt/dev/pts
	busybox mount -t proc proc $mnt/proc
	busybox mount -t sysfs sysfs $mnt/sys
	#mounting /dev/shm
	#swapon mswap
}

UmntBox() {
	inSide=true
	PDir=$mnt
	hasActiveP
	echo "stoping debox... "
	if [ -d $usrMnt/bin/ ]; then
		busybox umount $usrMnt
		busybox mount -o dirsync,nosuid,nodev,noexec,uid=1000,gid=1015,fmask=0702,dmask=0702 -t vfat $sdpart $sdcard
	fi
	busybox umount $mnt/dev/pts/
	busybox umount $mnt/proc/
	busybox umount $mnt/sys/
	busybox umount $mnt
	busybox rmdir $mnt
}

hasActiveP() {
	MPUSED=`lsof | grep $PDir | awk '{print $2}' | sort -u`
	if [ -n "$MPUSED" ] ; then
		echo "$PDir has active processes"
		echo $(lsof | grep $PDir | awk '{print $1}' | sort -u)
		echo "do you want to kill them? [y/n]"
		read yesno
		if [ "$yesno" = "y" ]; then
			for i in $MPUSED; do
					if [ $inSide ]; then
						busybox chroot $mnt /bin/bash -c "kill -s SIGKILL $i"
					else
						kill $i
					fi
			done
		else
			echo "Prosess will not be killed"
			if [ $inSide ]; then echo "Atention Debian is mounted! [debox stop]"; fi
			exit
		fi
	fi
}

GetHome() {
	inSide=false
	PDir=$sdcard
	hasActiveP
	if [ ! -d $mnt ]; then MntBox; fi
	busybox umount $sdcard
	busybox mount -o nodev,uid=1000,gid=1000,fmask=0002,dmask=0002 -t vfat $sdpart $usrMnt
}

if [ "$1" == "sd" ]; then
	if [ -d $mnt ]; then
		if [ -d $usrMnt/bin/ ]; then
			echo "for exiting, exit first this terminal and than the others!"
		else
			GetHome
		fi
		busybox chroot $mnt /bin/bash -c "cd /home/$usr/ && su $usr"
	else
		GetHome
		busybox chroot $mnt /bin/bash -c "cd /home/$usr/ && su $usr"
		UmntBox
	fi
elif [ "$1" == "root" ]; then
	if [ -d $mnt ]; then
		echo "for exiting, exit first this terminal and than the others!"
		busybox chroot $mnt /bin/bash
	else
		MntBox
		busybox chroot $mnt /bin/bash
		UmntBox
	fi
elif [ "$1" == "start" ]; then
	MntBox
	echo "for stoping debox, run [debox stop]"
elif [ "$1" == "startsd" ]; then
	GetHome
	echo "for stoping debox, run [debox stop]"
elif [ "$1" == "stop" ]; then
	if [ -d $mnt ]; then
		UmntBox
	else
		echo "debox is not started"
	fi
else
	if [ -d $mnt ] && [ $@ ]; then
			busybox chroot $mnt /bin/bash -c $@
	else
		echo "debox is not started, run [debox start]"
	fi
fi
