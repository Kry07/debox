# Global Variables, please fill up.
# the first two partitons should be empty.
export d_uuid="5df812fc-35a0-409a-8ba2-220d02cf08aa"
# swapon unterschtüzt leider keine UUID
export swp_part="/dev/block/mmcblk1p2"
export sd_uuid="76C1-F957"

# These Variables are in Android, please check.
#export sdcard=/mnt/external_sd
export andsys_part="/dev/block/mmcblk0p3"
export sdcard="/storage/sdcard1"

# Optional to edit
export usr="icony"
export mnt="/data/local/debian"
export usrMnt="$mnt/home/$usr/sdcard"
export debian_version="wheezy"
# Use armel, if your phone do support ARMv7 use armhf. 
export and_arch="armhf"
# check if source.list is compatible with $debian_version
export debian_server="http://ftp.us.debian.org/debian"
export hostName="icony07"
