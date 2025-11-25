#!/bin/bash

source /install/post/config
source /install/post/packer

echo $DISKPROC;
echo $DISKDATA;

if [[ ! -z $(findmnt --mountpoint /mnt) ]]; then 
 	umount -R /mnt
fi

mkfs.vfat -F32 -S 4096 -n BOOT $DISKBOOT &&
mkfs.ext4 -F -b 4096 $DISKPROC &&
mkfs.ext4 -F -b 4096 $DISKDATA &&

mount  $DISKPROC /mnt &&
mkdir -p /mnt/boot &&
mount -o uid=0,gid=0,dmask=007,fmask=007 $DISKBOOT /mnt/boot/ &&
mkdir -p /mnt/home &&
mount  $DISKDATA /mnt/home &&

# PROCESSOR
procieidven=$(grep "vendor_id" /proc/cpuinfo | head -n 1 | awk '{print $3}')

if [[ "$procieidven" == "GenuineIntel" ]]; then
    pacstrap /mnt intel-ucode $DISTRO_INSTALLATION_PACKAGE 
elif [[ "$procieidven" == "AuthenticAMD" ]]; then
    pacstrap /mnt amd-ucode $DISTRO_INSTALLATION_PACKAGE  
fi


# GRAPHICAL
graphidven=$(lspci | grep -i --color 'vga\')

if [[ ! -z $(echo $graphidven | grep -i --color 'Intel Corporation') ]];then
    echo "graphic intel"
fi

if [[ ! -z $(lspci | grep -i --color '3d\|NVIDIA') ]];then
    echo "graphic nvidia"
fi

if [[ ! -z $(lspci | grep -i --color '3d\|RADEON') ]];then
    echo "graphic radeon"
fi


genfstab -U /mnt > /mnt/etc/fstab &&
cp -fr /install/post /mnt &&


arch-chroot /mnt /bin/bash /post/init.sh
