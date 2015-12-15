#!/bin/bash -x
# run this script after stock install of 13.2.5 to create enhanced SD card 

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

cd $SCRIPTPATH
# the downloading requires more /tmp than in the olpc build
grep size=200 /etc/fstab
if [ $? -ne 0 ]; then
		  sed -i -e 's|^/tmp.*$|/tmp	/tmp	tmpfs	rw,size=200m	0	0|' /etc/fstab
		  sed -i -e 's|^vartmp.*$|vartmp	/vartmp	tmpfs	rw,size=200m	0	0|' /etc/fstab
        cp /home/olpc/.bash* /root/
        sed -i -e 's/^TEMPORARY_STATE.*/TEMPORARY_STATE=no/' /etc/sysconfig/readonly-root
		  reboot
fi
cp ../yum/rpmfusion.repo /etc/yum.repos.d

cd /root
# the stock kernel does not have bridge module
wget http://download.unleashkids.org/xsce/downloads/os/kernel_1.5/kernel-3.3.8_xo1.5-20150718.1548.olpc.313c677.i686.rpm
yum -y localinstall ./kernel*

# gcc 7.0 does not compile cmdsrv correctly
yum -y remove gcc
yum install -y git ansible tree vim firefox mlocate linux-firmware \
	gstreamer1-plugins-ugly	gstreamer1-plugins-bad-free-extras \
	gstreamer1-plugins-bad-freeworld	gstreamer1-plugins-base-tools \
	gstreamer1-plugins-good-extra	gstreamer1-plugins-bad-free \
	gstreamer-plugins-ugly	gstreamer-plugins-bad \
	gstreamer-ffmpeg gstreamer1-libav httpd compat-gcc-43

gsettings set org.gnome.Epiphany restore-session-policy never
sed -i -e's/^Exec=.*/Exec=file:///library/index.html %U/ /usr/share/applications/epiphany.desktop
mkdir -p /opt/schoolserver
cd /opt/schoolserver
git clone https://github.com/XSCE/xsce --depth 1

# run the playbooks that install things we need on the xo1
cd /root
git clone https://github.com/XSCE/xsce-local --branch xo15

# install up to the console so that users can select their services
cd /opt/schoolserver/xsce

# the following does a restart and keeps this script from completing
./install-console # so just wait for the few minutes, and restart it
