#!/bin/bash -x
# These need to be run after the xsce playbook is run

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

# help named know the name of localhost
sed -i -e 's/schooserver1/myserver/' /var/named-xs/school.internal.zone.db

# copy the whole configuration tree to the target machine
$SCRIPTPATH/cp_15

# use systemd to process things at boot
systemctl enable xs-onboot.service

# turn off munin, which takes cpu every 5 minutes (remove executable bit)
chmod 644 /bin/munin-cron

# make named.root a synbolic link, so it can be switched for on/off internet
mv /var/named-xs/named.root /var/named-xs/named.root.real

# default startup is in  AP mode, no internet
ln -sf /var/named-xs/named.zero /var/named-xs/named.root

# tell dhcpd not to try to update named
sec -i -e 's/^ddns-update-style.*/ddns-update-style none;/' /etc/dhcpd-xs.conf

# we want GUI at boot
ln -sf /lib/systemd/system/graphical.target default.target

# switch the variables so that it defaults to sugar desktop
xs-iiab

echo "ALL DONE"

