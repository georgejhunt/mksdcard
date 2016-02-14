#!/bin/bash -x
# These need to be run after the xsce playbook is run

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

# copy the whole configuration tree to the target machine
$SCRIPTPATH/cp_15

# use systemd to process things at boot
systemctl enable xsce-onboot.service

# turn off munin, which takes cpu every 5 minutes (remove executable bit)
chmod 644 /bin/munin-cron

# make named.root a synbolic link, so it can be switched for on/off internet
mv /var/named-xs/named.root /var/named-xs/named.root.real
# default startup is in  AP mode, no internet
ln -sf /var/named-xs/named.zero /var/named-xs/named.root

# switch the variables so that it defaults to sugar desktop
xs-desktop
