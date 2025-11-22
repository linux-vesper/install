#!/bin/bash

source /install/post/config

echo $DISKPROC;
echo $DISKDATA;

if [[ ! -z $(findmnt --mountpoint /mnt) ]]; then 
 	umount -R /mnt
fi

if [[ ! -e /dev/mapper/proc ]]; then 
	cryptsetup luksOpen $DISKPROC proc
fi

if [[ ! -e /dev/mapper/data  ]]; then 
	cryptsetup luksOpen $DISKDATA data
fi


mkfs.vfat -F32 -S 4096 -n BOOT $DISKBOOT
mkfs.ext4 -F -q -b 4096 /dev/mapper/proc &&
mkfs.ext4 -F -q -b 4096 /dev/mapper/data &&

mount /dev/mapper/proc /mnt &&
mkdir -p /mnt/boot &&
mount -o uid=0,gid=0,dmask=007,fmask=007 $DISKBOOT /mnt/boot/ &&
mkdir -p /mnt/home &&
mount /dev/mapper/data /mnt/home &&

pacstrap /mnt base &&

genfstab -U /mnt > /mnt/etc/fstab &&
cp -fr $(pwd)/post /mnt &&


echo "[multilib]" >> /mnt/etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf

arch-chroot /mnt /bin/bash /post/init.sh
