#!/bin/bash

# Script by Zachary Powell
# modified by Kry07

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/sbin
export run_ssh=true
export run_vnc=false
export resolution="800x640"

if [ ! -f /root/DONOTDELETE.txt ]; then
export TERM=linux
export HOME=/root
export USER=icony
	echo "Starting first boot setup......."
	chmod a+rw  /dev/null
	chmod a+rw  /dev/ptmx
	chmod 1777 /tmp
	chmod 1777 /dev/shm
	chmod 755 /var/run/dbus
	echo "Creating User account (named $USER)"
	adduser $USER
	echo "shm /dev/shm tmpfs nodev,nosuid,noexec 0 0" >> /etc/fstab
	chown -R "$USER".users /home/$USER
	usermod -a -G admin $USER
	usermod -a -G android_bt,android_bt-net,android_inet,android_net-raw $USER
	echo "boot set" >> /root/DONOTDELETE.txt
fi

############################################################
# enable workaround for upstart dependent installs         #
# in chroot'd environment. this allows certain packages    #
# that use upstart start/stop to not fail on install.      #
# this means they will have to be launched manually though #
############################################################
dpkg-divert --local --rename --add /sbin/initctl > /dev/null 2>&1
ln -s /bin/true /sbin/initctl > /dev/null 2>&1

#################################################
# If VNC server should start we do it here with #
# given resolution and DBUS server              #
#################################################
if [ $run_vnc ]; then
	su debian -l -c "vncserver :0 -geometry $resolution"
	dbus-daemon --system --fork > /dev/null 2>&1

	echo "If you see the message 'New 'X' Desktop is localhost:0' then you are ready to VNC into your debian OS.."
	echo "If connection from a different machine on the same network as the android device use the address below:"
	ifconfig eth0 | awk '/inet addr/ {split ($2,A,":"); print A[2]}'
fi

############################################
# If SSH server should start we do it here #
############################################
if [ $run_ssh ]; then
	/etc/init.d/ssh start
	ifconfig eth0 | awk '/inet addr/ {split ($2,A,":"); print A[2]}'
fi

echo "To shut down the Linux environment, just enter 'exit' at this terminal"

###############################################################
# Spawn and interactive shell - this effectively halts script #
# execution until the spawning shell is exited (i.e. you want #
# to shut down vncserver and exit the debian environment)     #
###############################################################
/bin/bash -i

#########################################
# Disable upstart workaround and        #
# kill VNC server (and optionally SSH)  #
# Rename used xstartup to its first file#
#########################################
if [ $run_vnc == yes ]; then
	su debian -c "vncserver -clean -kill :0"
fi

if [ $run_ssh == yes ]; then
	/etc/init.d/ssh stop
fi
