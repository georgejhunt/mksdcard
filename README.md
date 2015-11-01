# mksdcard
mkxo10.sh -- script which accepts an os-builder image name (assumed to be in /root/olcp-os-builder/images/xo1/). Then it partitions an SD card, mounts it, and copies the lzma tarball. Other parts of this script appear to be oblolete (as is almost all of it -- since I've decided to start with a stock 13.2.5 olpc build)

8gb -- this script tries to copy desired kiwix content to the SD card -- assumes that the content is on the same machine located at /root/content/zims

xo-custom -- written by Jerry Vonau, incorporated into mktinycorexo  by James Cameron, perhaps useful in doing a chroot, and all of the assembly on a SD card on a larger machine.
