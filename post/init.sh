#!/bin/bash

source /post/config

#HOSTNAME
echo "eyerise" > /etc/hostname &&

## LOCALTIME 
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime &&
hwclock --systohc &&
timedatectl set-ntp true &&
timedatectl set-timezone $TIMEZONE &&


## CONFIG
cp -fr /post/base/* / &&


## LOCALE
locale-gen &&


# PROCESSOR
procieidven=$(grep "vendor_id" /proc/cpuinfo | head -n 1 | awk '{print $3}')

if [[ "$procieidven" == "GenuineIntel" ]]; then
    pacman -S intel-ucode  --noconfirm
elif [[ "$procieidven" == "AuthenticAMD" ]]; then
    pacman -S amd-ucode  --noconfirm
fi


# GRAPHICAL
graphidven=$(lspci | grep -i --color 'vga\')

if [[ ! -z $(echo $graphidven | grep -i --color 'Intel Corporation') ]];then
    echo "graphic intel"
fi

if [[ ! -z $(lspci | grep -i --color '3d\|NVIDIA') ]];then
    echo "graphic nvidia"
fi

if [[ ! -z $(lspci | grep -i --color '3d\|AMD\|AMD/ATI\|RADEON') ]];then
    echo "graphic radeon"
fi


## SERVICE
systemctl enable gdm &&
systemctl enable sshd &&
systemctl enable nginx &&
systemctl enable docker &&
systemctl enable dnsmasq &&
systemctl enable firewalld &&
systemctl enable update.timer &&
systemctl enable NetworkManager &&
systemctl enable --global pipewire-pulse &&
systemctl enable systemd-timesyncd.service &&
systemctl enable waydroid-container.service &&
systemctl enable --global gcr-ssh-agent.socket &&



## BOOTING
mkdir -p /boot/{efi,kernel,loader} &&
mkdir -p /boot/efi/{boot,linux,systemd,rescue} &&
mv /boot/vmlinuz-linux-zen /boot/*-ucode.img /boot/kernel/ &&
rm /etc/mkinitcpio.conf &&
rm -fr /etc/mkinitcpio.conf.d/ &&
rm /boot/initramfs-* &&
bootctl --path=/boot/ install &&


## EXECUTE
chmod +x /usr/local/xbin/* &&
chmod +x /usr/local/lbin/* &&
chmod +x /usr/local/rbin/* &&


## LUKSDISK
echo "rd.luks.name=$(blkid -s UUID -o value $DISKPROC)=root root=/dev/mapper/root" > /etc/cmdline.d/01-boot.conf &&
echo "data UUID=$(blkid -s UUID -o value $DISKDATA) none" >> /etc/crypttab &&
mkinitcpio -P &&


## WAYDROID
waydroid init -s GAPPS &&

## LARAVEL
composer global require laravel/installer &&

## USERADD
useradd -m $USERNAME &&
usermod -aG wheel $USERNAME &&
echo "add user passworrd" &&
passwd $USERNAME