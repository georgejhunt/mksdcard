# mksdcard
XO1
===
* The olpc-os-builder ini file I was able to craft did not transfer corectly to Gnome. So I shifted to the strategy of loading James Cameron's 13.2.5 image onto an SD card, and then modifying it with a bash script from there (making mkxo10.sh obsolete).
mkxo10.sh -- script which accepts an os-builder image name (assumed to be in /root/olcp-os-builder/images/xo1/). Then it partitions an SD card, mounts it, and copies the lzma tarball. Other parts of this script appear to be oblolete (as is almost all of it -- since I've decided to start with a stock 13.2.5 olpc build)

8gb -- this script tries to copy desired kiwix content to the SD card -- assumes that the content is on the same machine located at /root/content/zims

xo-custom -- written by Jerry Vonau, incorporated into mktinycorexo  by James Cameron, perhaps useful in doing a chroot, and all of the assembly on a SD card on a larger machine.

onxo10.sh -- originally written for the xo1, to implement the additional functions (openvpn, sshd, kiwix, maybe apache). But then I tested it on the XO1.5, and added the phrase to download and install my custom kernel (which includes the bridge module needed for wifi networking). The obvious next step is break up onxo10 into onxo1.0.sh, and onxo1.5.sh.
XS1.5
=====
The preference is to use OS builder to generate the base image (if gnome works on the 1.5) because I can disable the funny chroot/file layout required by Quanta, and the update in the field strategy.

