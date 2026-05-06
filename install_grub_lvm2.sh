#!/bin/sh
# set up removable grub for lvm partition destroyed by Windows
# run this in the live system

sudo -i
# load lvm2_member filesystem
apt-get install lvm2
vgscan
vgchange -ay
lvscan
# decrypt lvm
cryptsetup luksOpen /dev/...drive... kali-root
# mount lvm
cd /
mkdir /target
mount /dev/mapper/kali--vg-root /target
# install grub
for n in dev dev/pts proc sys sys/firmware/efi/efivars run etc/resolv.conf; do mount --bind /$n /target/$n; done
chroot /target
mount -a
grub-install --removable /dev/{drive_name}
update-grub
