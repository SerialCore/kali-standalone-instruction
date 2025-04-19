#!/bin/sh
# set up removable grub for lvm partition destroyed by Windows
# run this in the live system

sudo -i
# load lvm2_member filesystem
apt-get install lvm2
vgscan
vgchange -ay
lvscan
# mount lvm
cd /
mkdir /target
mount /dev/...vg... /target
# install grub
for n in dev dev/pts proc sys sys/firmware/efi/efivars run etc/resolv.conf; do mount --bind /$n /target/$n; done
chroot /target
mount -a
grub-install --removable /dev/...drive...
update-grub
