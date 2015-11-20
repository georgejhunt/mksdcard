#!/bin/bash -x
# resize the xo SD card to minumum size and zip it to current directory
# receive partition to shrink as parameter (must be last)

if [ $# -ne 1 ]; then
   echo "please add device partition to shrink"
   exit 1
fi
PARTITION=$1
DEVICE=${PARTITION:0:-1}
PART_DIGIT=${PARTITION: (-1)}
PART_START_SECTOR=`parted -sm  $DEVICE unit s print|cut -d: -f1,2|grep $PART_DIGIT:|cut -d: -f2`
start=${PART_START_SECTOR:0:-1}

# Automatically determine a size for the output disk image (including root
# and boot partitions).
#
# This is calculated by using resize2fs to shrink, then adding the space
# occupied by partition 1
auto_size(){
		  # fetch the size of /dev/sdb2
		  blocks4k=`e2fsck -n $PARTITION 2>/dev/null|grep blocks|cut -f5 -d" "|cut -d/ -f2`
		  #pick up the ending sector of partition that is just before the last
		  sectors=$(( start - 1 ))
		  total_sectors=$(( (blocks4k * 8) + sectors ))
}

resize_image()
# recieves parameter number of sectors in partition 2 or "auto"
{
	local disk_size=$1
	if [ "$disk_size" = "auto" ]; then
	   auto_size
	fi

	echo "Making partition of size $total_sectors sectors starting at $start"
read -p "pause for verification" ans

parted -s $DEVICE rm $PART_DIGIT
parted -s $DEVICE unit s mkpart primary ext4 $start $total_sectors
}

#auto_size /dev/sdb2
umount $PARTITION
e2fsck -f $PARTITION
resize2fs -M $PARTITION |grep Nothing
if [ $? -ne 0 ]; then
   resize_image auto
fi
umount $PARTITION 
e2fsck -f $PARTITION
last_sector=`parted -sm  $DEVICE unit s print|cut -d: -f1,3|grep $PART_DIGIT:|cut -d: -f2`
last=${last_sector:0:-1}
echo "last sector: $last"
read -p "what is filename for this image? " FILENAME
mkdir -p /root/images/any
dd if=$DEVICE of=/root/images/any/$FILENAME bs=512 count=$last
cd /root/images/any
zip $FILENAME.zip $FILENAME
