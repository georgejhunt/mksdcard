#!/bin/bash -x
# run this script after stock install of 13.2.5 to create enhanced SD card 
# note to myself: This script may have been scp'd to /root as a bootstrap

# the downloading requires more /tmp than in the olpc build
grep size=200 /etc/fstab
if [ $? -ne 0 ]; then
		  sed -i -e 's|^/tmp.*$|/tmp	/tmp	tmpfs	rw,size=200m	0	0|' /etc/fstab
		  sed -i -e 's|^vartmp.*$|vartmp	/vartmp	tmpfs	rw,size=200m	0	0|' /etc/fstab
        sed -i -e '/excludedocs/ d' /etc/rpm/macros.imgcreate
        cp /home/olpc/.bash* /root/
        sed -i -e 's/^TEMPORARY_STATE.*/TEMPORARY_STATE=no/' /etc/sysconfig/readonly-root
		  reboot
fi
yum install -y git
cd /root
git clone https://github.com/georgejhunt/mksdcard
cp /root/mksdcard/yum/rpmfusion.repo /etc/yum.repos.d
mkdir -p /etc/xsce
echo 32 > /etc/xsce/sd-size

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

yum install -y git ansible tree vim firefox mlocate  \
	gstreamer1-plugins-ugly	gstreamer1-plugins-bad-free-extras \
	gstreamer1-plugins-bad-freeworld	gstreamer1-plugins-base-tools \
	gstreamer1-plugins-good-extra	gstreamer1-plugins-bad-free \
	gstreamer-plugins-ugly	gstreamer-plugins-bad \
	gstreamer-ffmpeg gstreamer1-libav man man-db man-pages tuxmath tuxpaint

# accumulate the manual entries for selected programs already installed
yum reinstall -y tree epiphany nano gsettings
updatedb

cd
if [ ! -f /home/olpc/Activities/FotoToon.activity ];then
  wget http://activities.sugarlabs.org/es-ES/sugar/downloads/latest/4253/addon-4253-latest.xo
  unzip -d /home/olpc/Activities addon-4253-latest.xo
fi
if [ ! -f /home/olpc/Activities/TuxPaint.activity ];then
  wget http://download.unleashkids.org/HaitiOS/tux/TuxPaint-6.2.xo
  cp TuxPaint-6.2.xo /home/olpc/Activities
fi
if [ ! -f /home/olpc/Activities/TuxMath.activity ];then
  wget http://download.unleashkids.org/HaitiOS/tux/TuxMath-3.1.xo
  cp TuxMath-3.1.xo /home/olpc/Activities
fi

mkdir -p /opt/schoolserver
cd /opt/schoolserver
git clone https://github.com/XSCE/xsce --depth 1
# copy the xo1 unique playbook
cp /root/mksdcard/config/* /opt/schoolserver/xsce
cd /opt/schoolserver/xsce
# execute the specialized playbook that only installs openvpn and kiwix
./xo1-install

cd $SCRIPTPATH
# do the sparse copy of files that are unique to this unleashkids version
./cp_1

# the setuid bit does not copy properly 
chmod 4755 /usr/bin/xs-remote-on
chmod 4755 /usr/bin/xs-remote-off
su olpc -c 'gsettings set org.gnome.Epiphany restore-session-policy never'
sed -i -e's|^Exec=.*|Exec=/bin/epiphany file:///library/index.html %U|' /usr/share/applications/epiphany.desktop

echo "all done"

