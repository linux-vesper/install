#!/bin/bash

source /install/creamie/post/config

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

if [[ ! -e /dev/mapper/proc ]]; then
	exit
fi

if [[ ! -e /dev/mapper/data ]]; then
	exit
fi

if [[ -z $( vgs | grep proc ) ]]; then
	pvcreate /dev/mapper/proc &&
	vgcreate proc /dev/mapper/proc
fi

if [[ -z $( vgs | grep data ) ]]; then
	pvcreate /dev/mapper/data &&
	vgcreate data /dev/mapper/data
fi


PROCDISK=(root opts vars nets conf vlog vtmp vpac vaud temp docs)
DATADISK=(home repo)

for n in "${PROCDISK[@]}"
do
	if [[ ! -z /dev/proc/$n ]]; then
  		mkfs.ext4 -F -q -b 4096 /dev/proc/$n
	fi
done

for n in "${DATADISK[@]}"
do
	if [[ ! -z /dev/data/$n ]]; then
   		mkfs.ext4 -F -q -b 4096 /dev/data/$n
	fi
done


mkfs.vfat -F32 -S 4096 -n BOOT $DISKBOOT

if [[ -e /dev/data/host ]];then
	mkfs.btrfs -f /dev/data/host
fi


if [[ -e /dev/data/dock ]];then
  mkfs.btrfs -f /dev/data/dock
fi


mount /dev/proc/root /mnt &&

mkdir -p /mnt/{boot,home,opt,var,tmp,srv/http} && 

mount -o uid=0,gid=0,dmask=007,fmask=007 $DISKBOOT /mnt/boot/ &&
mount /dev/proc/opts /mnt/opt &&
mount /dev/proc/vars /mnt/var &&
mount /dev/proc/temp /mnt/tmp &&
mount /dev/proc/docs /mnt/srv/http &&
mount /dev/data/home /mnt/home &&


mkdir -p /mnt/var/{tmp,log,cache/pacman,lib/telnet,lib/config,lib/hoster,lib/docker} &&
mount /dev/proc/vtmp /mnt/var/tmp &&
mount /dev/proc/nets /mnt/var/telnet &&
mount /dev/proc/conf /mnt/var/lib/config &&
mount /dev/data/dock /mnt/var/lib/docker &&
mount /dev/data/host /mnt/var/lib/hoster &&


mount /dev/proc/vpac /mnt/var/cache/pacman &&
mkdir -p /mnt/var/cache/pacman/lib &&


mkdir -p /mnt/var/log/audit &&
mount /dev/proc/vaud /mnt/var/log/audit &&


mkdir -p /mnt/home/family &&
mount /dev/data/repo /mnt/home/family &&

pacstrap /mnt base &&

genfstab -U /mnt > /mnt/etc/fstab &&
cp -fr $(pwd)/post /mnt &&

echo "[multilib]" >> /mnt/etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf

arch-chroot /mnt /bin/bash /post/init.sh
