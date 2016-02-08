#!/bin/bash -x
# run this script after stock install of 13.2.6 to create enhanced SD card 

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
        sed -i -e '/excludedocs/ d' /etc/rpm/macros.imgcreate
        sed -i -e 's/^TEMPORARY_STATE.*/TEMPORARY_STATE=no/' /etc/sysconfig/readonly-root
		  reboot
fi
cp ../yum/rpmfusion.repo.secondary /etc/yum.repos.d
mkdir -p /etc/xsce

cd /root
# the stock kernel does not have bridge module
wget http://download.unleashkids.org/xsce/downloads/os/kernel_4/kernel-3.5.7_xo4-20151216.1806.olpc.d520550.armv7hl.rpm
yum -y localinstall ./kernel*

su olpc -c 'gsettings set org.gnome.Epiphany restore-session-policy never'
sed -i  's|^Exec=.*|Exec=/bin/epiphany http://myserver.lan \%U|' /usr/share/applications/epiphany.desktop

# gcc 7.0 does not compile cmdsrv correctly
yum -y remove gcc
yum install -y git ansible tree vim firefox mlocate linux-firmware \
	gstreamer1-plugins-ugly	gstreamer1-plugins-bad-free-extras \
	gstreamer1-plugins-bad-freeworld	gstreamer1-plugins-base-tools \
	gstreamer1-plugins-good-extra	gstreamer1-plugins-bad-free \
	gstreamer-plugins-ugly	gstreamer-plugins-bad \
	gstreamer-ffmpeg gstreamer1-libav httpd tuxmath tuxpaint tuxtype

# accumulate the manual entries for selected programs already installed
yum reinstall -y tree epiphany nano gsettings yum
updatedb

cd
if [ ! -d /home/olpc/Activities/FotoToon.activity ];then
  wget http://download.unleashkids.org/xsce/downloads/activities/fototoon-13.xo
  unzip -d /home/olpc/Activities fototoon-13.xo
fi
if [ ! -d /home/olpc/Activities/TypingTurtle.activity ];then
  wget http://download.unleashkids.org/xsce/downloads/activities/typing_turtle-29.xo
  unzip -d /home/olpc/Activities typing_turtle-29.xo
fi
if [ ! -d /home/olpc/Activities/TuxPaint.activity ];then
  wget http://download.unleashkids.org/HaitiOS/tux/TuxPaint-6.2.xo
  unzip -d /home/olpc/Activities TuxPaint-6.2.xo
fi
if [ ! -d /home/olpc/Activities/TuxMath.activity ];then
  wget http://download.unleashkids.org/HaitiOS/tux/TuxMath-3.1.xo
  unzip -d /home/olpc/Activities TuxMath-3.1.xo
fi
grep org.tuxmath /usr/share/sugar/data/activities.defaults
if [ $? -ne 0 ]; then
  echo org.tuxmath >> /usr/share/sugar/data/activities.defaults
fi
grep org.tuxpaint /usr/share/sugar/data/activities.defaults
if [ $? -ne 0 ]; then
  echo org.tuxpaint >> /usr/share/sugar/data/activities.defaults
fi
grep org.eq.FotoToon /usr/share/sugar/data/activities.defaults
if [ $? -ne 0 ]; then
  echo org.eq.FotoToon >> /usr/share/sugar/data/activities.defaults
fi
grep org.laptop.community.TypingTurtle /usr/share/sugar/data/activities.defaults
if [ $? -ne 0 ]; then
  echo org.laptop.community.TypingTurtle >> /usr/share/sugar/data/activities.defaults
fi

mkdir -p /opt/schoolserver
mkdir -p /etc/xsce
cd /opt/schoolserver
git clone https://github.com/XSCE/xsce --depth 1

# the Ansible playbook reboots if default target is not multiuser.target
ln -sf /lib/systemd/system/multi-user.target default.target

# install selected services, and most of the software
# put in a local_vars to select the desired services
cp -f $SCRIPTPATH/resources/local_vars.yml /opt/schoolserver/xsce/vars/

# the git repo at ka-lite errors out, after tree is copied, so just restart
echo "cd /etc/schoolserver/xsce;./runansible">/etc/rc.d/rc.local
chmod 755 /etc/rc.d/rc.local

cd /opt/schoolserver/xsce
./runansible

ln -sf /lib/systemd/system/graphical.target default.target

# copy the files that make this an unleashkids sdcard project
cd $SCRIPTPATH
./cp_4
xs-desktop

#echo "blacklist btmrvl_sdio" > /etc/modprobe.d/btmrvl.conf
echo ALL DONE
