#!/bin/bash

if [[ ! -z $(findmnt --mountpoint /mnt) ]]; then 
  umount -R /mnt
fi


PROCDISK=(root opts vars nets conf vlog vtmp vpac vaud temp docs)
DATADISK=(home repo)

for n in "${PROCDISK[@]}"
do
  mkfs.ext4 -F -q -b 4096 /dev/proc/$n
done

for n in "${DATADISK[@]}"
do
   mkfs.ext4 -F -q -b 4096 /dev/data/$n
done


mkfs.vfat -F32 -S 4096 -n BOOT /dev/nvme0n1p1 

if [[ -e /dev/data/host ]];then
	mkfs.btrfs -f /dev/data/host
fi


if [[ -e /dev/data/dock ]];then
  mkfs.btrfs -f /dev/data/dock
fi


mount /dev/proc/root /mnt &&

mkdir -p /mnt/{boot,home,opt,var,tmp,srv/http} && 

mount -o uid=0,gid=0,dmask=007,fmask=007 /dev/nvme0n1p1 /mnt/boot/ &&
mount /dev/proc/opts /mnt/opt &&
mount /dev/proc/vars /mnt/var &&
mount /dev/proc/temp /mnt/tmp &&
mount /dev/proc/docs /mnt/srv/http &&
mount /dev/data/home /mnt/home &&


mkdir -p /mnt/var/{tmp,log,cache/pacman,net,cfg,lib/hoster,lib/docker} &&
mount /dev/proc/vtmp /mnt/var/tmp &&
mount /dev/proc/nets /mnt/var/net &&
mount /dev/proc/conf /mnt/var/cfg &&
mount /dev/data/dock /mnt/var/lib/docker &&
mount /dev/data/host /mnt/var/lib/hoster &&


mount /dev/proc/vpac /mnt/var/cache/pacman &&
mkdir -p /mnt/var/cache/pacman/lib &&


mkdir -p /mnt/var/log/audit &&
mount /dev/proc/vaud /mnt/var/log/audit &&


mkdir -p /mnt/home/family &&
mount /dev/data/home /mnt/home/family &&

pacstrap /mnt base &&

genfstab -U /mnt > /mnt/etc/fstab &&
cp -fr post /mnt &&


arch-chroot /mnt /bin/bash /post/init.sh
