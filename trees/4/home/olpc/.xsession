# Copy this file to ~/.xsession to customize your X session
#
# Contents of this file are preserved on updates because it lives in your $HOME
# Check the master copy in /etc/skel/.xsession-example for updates
#

# To turn on debugging for Sugar components, see ~/.sugar/debug

# Uncomment the following line to enable core dumps
#ulimit -c unlimited

# Uncomment the following line to debug sugar startup problems
#exec xterm

# If you drop out of this script, the normal olpc-session will proceed
# Uncomment the following line to prevent it
#exit 0

#there seems some comfusion in olpc-session active vs desktop so make our own
if [ -f /home/olpc/.browser-at-boot ]; then
	if [ -f /home/olpc/.olpc-active-desktop ]; then
	   current=`cat /home/olpc/.olpc-active-desktop`
	fi

	if [ -z $current ]; then
	  current=sugar
	fi
	if [ "$current" == "sugar" ]; then
	   /home/olpc/.webstart &
	fi

	if [ "$current" == "gnome" ]; then
	   /home/olpc/.matestart &
	fi
fi
