# the three partitons should be empty.
export d_uuid="22e86a4a-8031-41f0-ac07-46eb2606df0d"
export sd_uuid="3D4D-232C"
export swp_uuid="370f91ca-0053-4be0-8f07-7808b2c83153"

export d_part=/dev/block/mmcblk2p3
export swp_part=/dev/block/mmcblk2p2
#export sd_part=/dev/block/vold/179:65
export sd_part=/dev/block/mmcblk2p1
export andsys_part=/dev/block/mmcblk0p3
# export sdcard=/mnt/external_sd
export sdcard=/storage/sdcard1
export mnt=/data/local/debian
export usr=icony
export usrMnt=$mnt/home/$usr/data
export debian_version="wheezy"
# check if source.list is compatible with $debian_version
export debian_server="http://ftp.de.debian.org/debian"
export hostName="icony07"
