#!/bin/bash -x
# run this script after stock install of 13.2.5 to create enhanced SD card 
# note to myself: This script may have been scp'd to /root as a bootstrap

# the downloading requires more /tmp than in the olpc build
grep size=200 /etc/fstab
if [ $? -ne 0 ]; then
		  sed -i -e 's|^/tmp.*$|/tmp	/tmp	tmpfs	rw,size=200m	0	0|' /etc/fstab
		  sed -i -e 's|^vartmp.*$|vartmp	/vartmp	tmpfs	rw,size=200m	0	0|' /etc/fstab
        cp /home/olpc/.bash* /root/
        sed -i -e 's/^TEMPORARY_STATE.*/TEMPORARY_STATE=no/' /etc/sysconfig/readonly-root
		  reboot
fi
yum install -y git
cd /root
git clone https://github.com/georgejhunt/mksdcard
cp /root/mksdcard/yum/rpmfusion.repo /etc/yum.repos.d
mkdir -p /etc/xsce

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

yum install -y git ansible tree vim firefox mlocate linux-firmware \
	gstreamer1-plugins-ugly	gstreamer1-plugins-bad-free-extras \
	gstreamer1-plugins-bad-freeworld	gstreamer1-plugins-base-tools \
	gstreamer1-plugins-good-extra	gstreamer1-plugins-bad-free \
	gstreamer-plugins-ugly	gstreamer-plugins-bad \
	gstreamer-ffmpeg gstreamer1-libav 

mkdir -p /opt/schoolserver
cd /opt/schoolserver
git clone https://github.com/XSCE/xsce --depth 1
cp /root/mksdcard/config/* /opt/schoolserver/xsce
cd /opt/schoolserver/xsce
./xo1-install

# get the repository  that installs files sparsely
cd /root
git clone https://github.com/XSCE/xsce-local --branch xo1
./xsce-local/scripts/cp-root
# the setuid bit does not copy properly 
chmod 4755 /usr/bin/xs-remote-on
chmod 4755 /usr/bin/xs-remote-off
su olpc -c "gsettings set org.gnome.Epiphany restore-session-policy never"
sed -i -e's/^Exec=.*/Exec=file:///library/index.html %U/ /usr/share/applications/epiphany.desktop

# establish a reasonable base of installed packages
#cd /opt/schoolserver/xsce
#./runtags download
# the following does a restart and keeps this script from completing
#./install-console

echo "all done"
