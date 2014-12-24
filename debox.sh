export PATH=$bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
export TERM=linux
export HOME=/root
export USER=root

busyBmnt() {
	if [ -z "$3" ]; then
		echo "error: mount variable is not set"
	fi

	busybox mount -t $1 $2 $3

	if [ $? -ne 0 ]; then 
		echo "error: Unable to mount $mpart from type $mtyp to $mdir"
		UmntBox
		exit
	fi
}

hasActiveP() {
	MPUSED=`lsof | grep $2 | awk '{print $2}' | sort -u`
	if [ -n "$MPUSED" ] ; then
		echo "$2 has active processes"
		echo $(lsof | grep $2 | awk '{print $1}' | sort -u)
		echo "do you want to kill them? [y/n]"
		read yesno
		if [ "$yesno" = "y" ]; then
			for i in $MPUSED; do
				if [ $1 -ne 0 ]; then
					busybox chroot $mnt /bin/bash -c "kill -s SIGKILL $i"
				else
					kill $i
				fi
			done

		else
			echo "Prosess will not be killed"
			if [ $1 -ne 0 ]; then
				echo "Atention Debian is mounted! [debox stop]"
				exit
			fi
		fi
	fi
}

MntBox() {
	echo "starting debox... "
	busybox mkdir -p $mnt
	busyBmnt ext4 $d_part $mnt
	busyBmnt devpts devpts $mnt/dev/pts
	busyBmnt proc proc $mnt/proc
	busyBmnt sysfs sysfs $mnt/sys
	swapon $swp_part
}

UmntBox() {
	hasActiveP 1 $mnt
	echo "stoping debox... "
	if [ -d $usrMnt ]; then
		busybox umount $usrMnt
		busyBmnt vfat $sd_part $sdcard
	fi
	busybox umount $mnt/dev/pts/
	busybox umount $mnt/proc/
	busybox umount $mnt/sys/
	busybox umount $mnt
	busybox rmdir $mnt
}

GetHome() {
	hasActiveP 0 $sdcard
	if [ ! -d $mnt ]; then
		MntBox
	fi
	busybox umount $sdcard
	busybox mount -o nodev,uid=1000,gid=1000,fmask=0002,dmask=0002 -t vfat $sd_part $usrMnt
}

if [ "$1" == "sd" ]; then
	if [ -d $mnt ]; then
		if [ -d $usrMnt ]; then
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
