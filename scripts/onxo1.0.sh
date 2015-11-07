#!/bin/bash -x
# run this script after stock install of 13.2.5 to create enhanced SD card 
# note to myself: This script may have been scp'd to /root as a bootstrap

yum install -y git
cd /root
git clone https://github.com/georgejhunt/mksdcard
cp /root/mksdcard/yum/rpmfusion.repo /etc/yum.repos.d

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

yum install -y git ansible tree vim firefox mlocate linux-firmware \
	gstreamer1-plugins-ugly	gstreamer1-plugins-bad-free-extras \
	gstreamer1-plugins-bad-freeworld	gstreamer1-plugins-base-tools \
	gstreamer1-plugins-good-extra	gstreamer1-plugins-bad-free \
	gstreamer-plugins-ugly	gstreamer-plugins-bad \
	gstreamer-ffmpeg gstreamer1-libav httpd

mkdir -p /opt/schoolserver
cd /opt/schoolserver
git clone https://github.com/XSCE/xsce --depth 1
cp /root/mksdcard/config/* /opt/schoolserver/xsce
cd /opt/schoolserver/xsce
./xo1-install

# run the playbooks that install things we need on the xo1
cd /root
git clone https://github.com/XSCE/xsce-local --branch xo15

# establish a reasonable base of installed packages
#cd /opt/schoolserver/xsce
#./runtags download
# the following does a restart and keeps this script from completing
#./install-console

echo "all done"