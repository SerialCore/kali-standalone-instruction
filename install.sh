#!/bin/sh

# 1. partition of the target usb drive using gdisk
#/dev/sda1,   4.0 GiB, type 8301, Linux reserved, will become /boot
#/dev/sda2,   2.0 MiB, type ef02, BIOS boot, will contain grub2
#/dev/sda3, 128.0 MiB, type ef00, EFI system partition
#/dev/sda4,   8.0 GiB, type 8200, Linux swap
#/dev/sda5,  <something big>, type 8300, Linux filesystem, will be the main partition

# 2. encrypt and format the partitions
sudo cryptsetup luksFormat --type=luks1 /dev/sdn1
sudo cryptsetup luksFormat /dev/sdn4
sudo cryptsetup luksFormat /dev/sdn5

sudo cryptsetup open /dev/sdn1 LUKS_BOOT
sudo cryptsetup open /dev/sdn4 LUKS_SWAP
sudo cryptsetup open /dev/sdn5 LUKS_ROOT
sudo mkfs.ext4 -L boot /dev/mapper/LUKS_BOOT
sudo mkfs.vfat -F 16 -n EFI-SP /dev/sdn3
sudo mkswap -L swap /dev/mapper/LUKS_SWAP
sudo mkfs.btrfs -L root /dev/mapper/LUKS_ROOT
sudo cryptsetup close LUKS_BOOT
sudo cryptsetup close LUKS_SWAP
sudo cryptsetup close LUKS_ROOT

# 3. prepare the scripts
sed -i "s@WhatUUID@$(sudo blkid -s PARTUUID -o value /dev/sdn3)@g" fstab
sed -i "s@BOOTUUID@$(sudo blkid -s UUID -o value /dev/sdn1)@g" crypttab
sed -i "s@SWAPUUID@$(sudo blkid -s UUID -o value /dev/sdn4)@g" crypttab
sed -i "s@ROOTUUID@$(sudo blkid -s UUID -o value /dev/sdn5)@g" crypttab

# 4. boot kali installer
# ...
# Configure the clock

# hold [Ctrl]+[Alt]+[F3]
cryptsetup open /dev/sdn1 LUKS_BOOT
cryptsetup open /dev/sdn4 LUKS_SWAP
cryptsetup open /dev/sdn5 LUKS_ROOT

# hold [Ctrl]+[Alt]+[F5]
# Detect disks
# Partition disks, manual

# hold [Ctrl]+[Alt]+[F3]
mkdir -p /point/
mount -o subvol=/ /dev/mapper/LUKS_ROOT /point
cd /point/
# keep only the following subvolumes
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @root
btrfs subvolume list .
btrfs subvolume set-default 256 . # where 256 is the subvolume ID that was displayed for @

# umount all /target
mount -o subvol=@ /dev/mapper/LUKS_ROOT /target
mkdir -p /target/boot
mkdir -p /target/boot/efi
mount /dev/mapper/LUKS_BOOT /target/boot
mount /dev/sdn3 /target/boot/efi
mount -o subvol=@home /dev/mapper/LUKS_ROOT /target/home
mount -o subvol=@root /dev/mapper/LUKS_ROOT /target/root
cp fstab /target/etc
cp crypttab /target/etc

# 5. actual installation
# hold [Ctrl]+[Alt]+[F5]
# ...
# Continue without boot loader

# 6. set up initial ram disk
# hold [Ctrl]+[Alt]+[F3]
for n in dev proc sys run etc/resolv.conf; do mount --bind /$n /target/$n; done
chroot /target
mount -a
apt-get install grub-common grub-efi-amd64 os-prober
apt-get install cryptsetup-initramfs

echo "KEYFILE_PATTERN=/etc/luks/*.keyfile" >>/etc/cryptsetup-initramfs/conf-hook
echo "UMASK=0077" >>/etc/initramfs-tools/initramfs.conf
mkdir -p /etc/luks
dd if=/dev/urandom of=/etc/luks/boot_os.keyfile bs=4096 count=1
chmod u=rx,go-rwx /etc/luks
chmod u=r,go-rwx /etc/luks/boot_os.keyfile
cryptsetup luksAddKey /dev/sdn1 /etc/luks/boot_os.keyfile
cryptsetup luksAddKey /dev/sdn4 /etc/luks/boot_os.keyfile
cryptsetup luksAddKey /dev/sdn5 /etc/luks/boot_os.keyfile
/usr/sbin/update-initramfs -u -k all

# hold [Ctrl]+[Alt]+[F5]
# Finish the installation with system clock set to UTC

# 7. set up removable grub
# must run in the live system
sudo -i
cryptsetup open /dev/sdn1 LUKS_BOOT
cryptsetup open /dev/sdn5 LUKS_ROOT
cd /
mkdir -p /target
mount /dev/mapper/LUKS_ROOT /target
mount /dev/mapper/LUKS_BOOT /target/boot
mount /dev/sdn3 /target/boot/efi

for n in dev dev/pts proc sys sys/firmware/efi/efivars run etc/resolv.conf; do mount --bind /$n /target/$n; done
chroot /target
mount -a

echo "GRUB_ENABLE_CRYPTODISK=y" >>/etc/default/grub
grub-install --removable /dev/sdn
update-grub
