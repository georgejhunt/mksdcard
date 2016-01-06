#!/bin/bash -x
# resize the xo SD card to minumum size and zip it to current directory
# assume the /dev/sdb2 is partition to be shrunk

DEVICE=/dev/sdb
PART=${DEVICE}2
BLOCK_SIZE=512
ROOT_PARTITION_START_BLOCK=139264
NUM_HEADS=16
NUM_SECTORS_PER_TRACK=62
CHKDEV=`blkid|grep OLPCRoot|cut -d" " -f 1`
echo $CHKDEV
if [ "$CHKDEV" != "$PART:" ];then
   echo "OLPCRoot not at expected location"
   #exit 1
fi

# Automatically determine a size for the output disk image (including root
# and boot partitions).
#
# This is calculated by using resize2fs to shrink, then adding the space
# occupied by partition 1
auto_size(){
		  # fetch the size of /dev/sdb2
		  blocks4k=`e2fsck -n $PART 2>/dev/null|grep blocks|cut -f5 -d" "|cut -d/ -f2`
		  #pick up the ending sector of first partition
		  sectors=`fdisk -l|grep ${DEVICE}1|gawk '{print $4}'`
		  total_sectors=$(( $blocks4k * 8 + $sectors ))
		  newsectors=$(( $blocks4k * 8 ))
}

resize_image()
# recieves parameter number of sectors in partition 2 or "auto"
{
	local disk_size=$1
	if [ "$disk_size" = "auto" ]; then
	   auto_size
		part_size=${newsectors}
	fi

	echo "Making partition of size $part_size"
#read -p "pause for verification" ans

	/sbin/sfdisk -S 32 -H 32 --force -uS $DEVICE <<EOF
8192,131072,83,*
$ROOT_PARTITION_START_BLOCK,$part_size,,
EOF
}

# put in a test for haveing run sysprep
if [ -f /.olpc-configured ]; then
  echo "/.olpc-cofigured exists. Have you run xs-sysprep? "
  exit 1
fi

#auto_size /dev/sdb2
umount $PART
umount /media/usb*
e2fsck -f $PART
resize2fs -M $PART

resize_image auto
umont $PART
e2fsck -f $PART
read -p "what is filename for this image? " FILENAME
FILENAME=$FILENAME.img
dd if=$DEVICE of=/root/images/xo1/$FILENAME bs=512 count=$total_sectors
cd /root/images/xo1
zip $FILENAME.zip $FILENAME
md5sum $FILENAME > $FILENAME.md5.txt
md5sum $FILENAME.zip > $FILENAME.zip.md5.txt
