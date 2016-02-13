#!/bin/bash -x
# These need to be run after the xsce playbook is run

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

$SCRIPTPATH/cp_15
# turn off munin, which takes cpu every 5 minutes
chmod 644 /bin/munin-cron

# make named.root a synbolic link, so it can be switched for on/off internet
mv /var/named-xs/named.root /var/named-xs/named.root.real
# default startup is in  AP mode, no internet
ln -sf /var/named-xs/named.zero /var/named-xs/named.root

xs-desktop
