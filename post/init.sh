#!/bin/bash

source /post/config

#HOSTNAME
echo "vesper" > /etc/hostname &&

## LOCALTIME 
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime &&
hwclock --systohc &&
timedatectl set-ntp true &&
timedatectl set-timezone $TIMEZONE &&


## CONFIG
cp -fr /post/base/* / &&


## LOCALE
locale-gen &&


## SERVICE
systemctl enable sddm &&
systemctl enable iwd &&
systemctl enable sshd &&
systemctl enable nginx &&
systemctl enable docker &&
systemctl enable dnsmasq &&
systemctl enable firewalld &&
systemctl enable update.timer &&
systemctl enable NetworkManager &&
systemctl enable --global pipewire-pulse &&
systemctl enable systemd-timesyncd.service &&
systemctl enable --global gcr-ssh-agent.socket &&



## BOOTING
mkdir -p /boot/{efi,kernel,loader} &&
mkdir -p /boot/efi/{boot,linux,systemd,rescue} &&
mv /boot/vmlinuz-linux-lts /boot/*-ucode.img /boot/kernel/ &&
rm /etc/mkinitcpio.conf &&
rm -fr /etc/mkinitcpio.conf.d/ &&
rm /boot/initramfs-* &&
bootctl --path=/boot/ install &&


## EXECUTE
chmod +x /usr/local/xbin/* &&
chmod +x /usr/local/lbin/* &&
chmod +x /usr/local/rbin/* &&


## LUKSDISK
echo "root=$DISKPROC" > /etc/cmdline.d/01-boot.conf &&
mkinitcpio -P &&


## USERADD
useradd -m $USERNAME &&
usermod -aG wheel $USERNAME &&
echo "add user passworrd" &&
passwd $USERNAME