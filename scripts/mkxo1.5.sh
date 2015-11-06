#!/bin/bash -x
# This script receives OS build number as paramater, builds base SD card for 1.5

if [ $# -ne 1 ]; then
  echo "Pass the name of OS-builder file (located in /root/images/)as first parameter"
  exit 1
fi
if [ ! -f /root/olpc-os-builder/images/1.0/$1/$1.tree.tar.lzma ];then
  echo "/root/olpc-os-builder/images/1.0/$1/$1.tree.tar.lzma not found"
  exit 1
fi 

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

DEV=/dev/sdb
umount /media/usb*
umount ${DEV}3
umount ${DEV}1 
umount ${DEV}2 

# first create partitions for XO1.0 SD card
parted --script ${DEV} print

parted --script ${DEV} mklabel msdos

parted --script --align optimal ${DEV} unit MB mkpart primary ext2 4MB 60MB
parted --script ${DEV} set 1 boot on
parted --script --align optimal ${DEV} unit MB 'mkpart primary ext4 61MB -1s'
partprobe
parted --script ${DEV} print
sleep 10

# partprobe tends to automount partitions
umount /media/usb*

mkfs.ext2 ${DEV}1 -L Boot 
mkfs.ext4 ${DEV}2 -L OLPCRoot 

mount ${DEV}2 /mnt
mkdir -p /mnt/bootpart
mount ${DEV}1 /mnt/bootpart
mkdir /mnt/bootpart/boot

# copy the tar file to the newly formatted SD card
echo "writing tar file to SD card"
tar xfJ /root/olpc-os-builder/images/1.0/$1/$1.tree.tar.lzma -C /mnt 

cp /mnt/boot/* --no-dereference /mnt/bootpart/boot/
echo "copy of OS to SD completed"

# fetch the content local to this distribution
cd /root
git clone https://github.com/XSCE/xsce-local --branch xo1

# fetch the XSCE playbook
mkdir -p /mnt/opt/schoolserver
cd /mnt/opt/schoolserver
git clone https://github.com/XSCE/xsce --depth 1
cd xsce

# bypass all the interactive console stuff by copying in our own local-vars
#  which installs, and enables the default set of capabilities for the SD1.5

mv  vars/local_vars.yml /vars/local_vars.save
cp -f $SCRIPTPATH/local_vars.yml vars/
git runansible
if [ $? -eq 0 ]; then
   mv - f vars/local_vars.save vars/local_vars.yml
else
   echo "The git playbook did not run to completion successfully"
   echo "  Please correct, and then move vars/local_vars.save to vars/local_vars.yml"

fi

