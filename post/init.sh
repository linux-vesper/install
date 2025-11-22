#!/bin/bash

source /post/config

## LOCALTIME 
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime &&
hwclock --systohc &&
timedatectl set-ntp true &&
timedatectl set-timezone Asia/Jakarta &&


## LOCALES
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen  
echo "en_US ISO-8859-1" >> /etc/locale.gen   
locale-gen &&

## INSTALL
pacman -Syy --noconfirm &&
pacman -R iptables --noconfirm &&
pacman -S linux-zen\
    scx-scheds \
    wireless-regdb \
    mkinitcpio \
    base-devel \
    mesa \
    konsole \
    linux-firmware \
    sof-firmware \
    openssh \
    iptables-nft \
    firewalld \
    bluez-utils \
    dnsmasq \
    networkmanager \
    neovim \
    dolphin \
    jack2 \
    pipewire \
    wireplumber \
    pipewire-alsa \
    pipewire-pulse \
    ttf-droid \
    kitty-terminfo \
    bash-completion \
    git \
    wget \
    unzip \
    flatpak \
    discover \
    fuse \
    btop \
    sddm \
    sddm-kcm \
    firefox \
    kwallet \
    weston \
    plasma \
    kwalletmanager \
    aria2 \
    krita \
    blender \
    hiprt \
    inkscape \
    gimp \
    carla \
    tenacity \
    qtractor \
    hydrogen \
    yoshimi \
    digikam \
    sweethome3d \
    breeze-icons \
    darktable \
    scribus \
    keepassxc \
    waydroid  --noconfirm &&


if [[ $INTELPRO == true ]]; then
    pacman -S intel-ucode  --noconfirm
else
    pacman -S amd-ucode  --noconfirm
fi


## CONFIG
cp -fr /post/base/* / &&


## LOCALE
locale-gen &&

##
## SERVICE
systemctl enable sddm &&
systemctl enable sshd &&
systemctl enable dnsmasq &&
systemctl enable firewalld &&
systemctl enable update.timer &&
systemctl enable NetworkManager &&
systemctl enable --global pipewire-pulse &&
systemctl enable systemd-timesyncd.service &&
systemctl enable waydroid-container.service

## enable waydroid
waydroid init -s GAPPS &&

##
## BOOTUPS
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
echo "data UUID=$(blkid -s UUID -o value $DISKDATA) none" >> /etc/crypttab 
mkinitcpio -P

## USERADD
useradd -m $USERNAME &&
usermod -aG wheel $USERNAME &&
echo "add user passworrd" &&
passwd  $USERNAME
