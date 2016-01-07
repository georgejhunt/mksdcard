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
cp ../yum/rpmfusion.repo /etc/yum.repos.d
mkdir -p /etc/xsce

cd /root
# the stock kernel does not have bridge module
wget http://download.unleashkids.org/xsce/downloads/os/kernel_1.5/kernel-3.3.8_xo1.5-20150718.1548.olpc.313c677.i686.rpm
yum -y localinstall ./kernel*

su olpc -c 'gsettings set org.gnome.Epiphany restore-session-policy never'
sed -i -e's|^Exec=.*|Exec=/bin/epiphany http://myserver.lan %U|' /usr/share/applications/epiphany.desktop

# gcc 7.0 does not compile cmdsrv correctly
yum -y remove gcc
yum install -y git ansible tree vim firefox mlocate linux-firmware \
	gstreamer1-plugins-ugly	gstreamer1-plugins-bad-free-extras \
	gstreamer1-plugins-bad-freeworld	gstreamer1-plugins-base-tools \
	gstreamer1-plugins-good-extra	gstreamer1-plugins-bad-free \
	gstreamer-plugins-ugly	gstreamer-plugins-bad \
	gstreamer-ffmpeg gstreamer1-libav httpd 

# accumulate the manual entries for selected programs already installed
yum reinstall -y tree epiphany nano gsettings yum
updatedb

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
cd $SCRIPTPATH
$SCRIPTPATH/cp_15
xs-desktop
echo ALL DONE
