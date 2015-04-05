export PATH=$bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
export TERM=linux
export HOME=/root
export USER=root

busyBmnt() {
	vfstype=$1; device=$2; dir=$3; options=$4

	if [ -z "$3" ] || [ ! -z "$5" ]; then
		echo "error: mount variable is not set"
	else
		if [ -z "$options" ]; then
			busybox mount -t $vfstype $device $dir >&2
		else
			busybox mount -t $vfstype $device $dir -o $options >&2
		fi

		if [ $? -ne 0 ]; then 
			echo "error: Unable to mount $device from type $vfstype to $dir"
			UmntBox
			exit
		fi
	fi
}

#insideD > inside Debox = true / false
hasActiveP() {
	insideD=$1; dir=$2

	MPUSED=`lsof | grep $dir | awk '{print $2}' | sort -u`
	if [ -n "$MPUSED" ] ; then
		echo "$2 has active processes"
		echo $(lsof | grep $dir | awk '{print $1}' | sort -u)
		echo "do you want to kill them? [y/n]"
		read yesno
		if [ "$yesno" = "y" ]; then
			for i in $MPUSED; do
				if [ $insideD -ne 0 ]; then
					busybox chroot $mnt /bin/bash -c "kill -s SIGKILL $i"
				else
					kill $i
				fi
			done

		else
			echo "Prosess will not be killed"
			if [ $insideD -ne 0 ]; then
				echo "Atention Debian is mounted! [debox stop]"
				exit
			fi
		fi
	fi
}

MntBox() {
	echo "starting debox... "
	busybox mkdir -p $mnt
	busyBmnt ext4 UUID="$d_uuid" $mnt
	busyBmnt devpts devpts $mnt/dev/pts
	busyBmnt proc proc $mnt/proc
	busyBmnt sysfs sysfs $mnt/sys
	swapon -U $swp_uuid
}

UmntBox() {
	hasActiveP 1 $mnt
	echo "stoping debox... "
	if [ -d $usrMnt ]; then
		busybox umount $usrMnt
		busybox rmdir $usrMnt
		echo "Now go to Settings > Storage > Mount SD card"
	fi
	busybox umount $mnt/dev/pts/
	busybox umount $mnt/proc/
	busybox umount $mnt/sys/
	busybox umount $mnt
	busybox rmdir $mnt
}

GetHome() {
	hasActiveP 0 $sdcard
	buysbox umount $sdcard

	if [ ! -d $mnt ]; then
		MntBox
	fi
	busybox mkdir -p $usrMnt
	busyBmnt vfat UUID="$sd_uuid" $usrMnt nodev,uid=1000,gid=1000,umask=013
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
