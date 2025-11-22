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


## DIRECTO
mkdir /opt/flat &&
ln -sf /opt/flat /var/lib/flatpak &&

## INSTALL
pacman -Syy --noconfirm &&
pacman -S linux-zen\
    scx-scheds \
    wireless-regdb \
    amd-ucode \
    mkinitcpio \
    base-devel \
    mesa \
    konsole \
    linux-firmware \
    sof-firmware \
    openssh \
    firewalld \
    bluez-utils \
    dnsmasq \
    networkmanager \
    neovim \
    dolphin \
    pipewire \
    pipewire-alsa \
    pipewire-jack \
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
    firefox \
    kwallet \
    plasma-nm \
    ksshaskpass \
    kwallet-pam \
    plasma-desktop \
    kwalletmanager \
    aria2 \
    krita \
    blender \
    hiprt \
    --noconfirm &&

if [[ ! -z $( lscpi | grep NVIDIA ) ]]; then
    pacman -S cuda 
fi

if [[ ! -z $( lscpi | grep AMD ) ]]; then
    pacman -S hip-runtime-amd 
fi

## CONFIG
cp -fr /post/base/* / &&
cp -fr /post/extra/amd/* / &&


## LOCALE
locale-gen &&

##
## SERVICE
systemctl enable lightdm &&
systemctl enable dnsmasq &&
systemctl enable update.timer &&
systemctl enable NetworkManager &&
systemctl enable --global pipewire-pulse &&
systemctl enable systemd-timesyncd.service &&
# systemctl enable waydroid-container.service


##
## BOOTUPS
mkdir -p /boot/{efi,kernel,loader}
mkdir -p /boot/efi/{boot,linux,systemd,rescue}
mv /boot/vmlinuz-linux-lqx /boot/amd-ucode.img /boot/kernel/
rm /etc/mkinitcpio.conf
rm -fr /etc/mkinitcpio.conf.d/
rm /boot/initramfs-*
bootctl --path=/boot/ install


## EXECUTE
chmod +x /usr/xbin/* &&
chmod +x /usr/pbin/* &&


## LUKSDISK
echo "rd.luks.name=$(blkid -s UUID -o value $DISKPROC)=root root=/dev/proc/root" > /etc/cmdline.d/01-boot.conf &&
echo "data UUID=$(blkid -s UUID -o value $DISKDATA) none" >> /etc/crypttab 
mkinitcpio -P

## ADMIN ADD
useradd -d /var/lib/telnet -u 23 net &&
usermod -aG wheel net &&
chown -R net:net /var/lib/telnet &&
passwd net


## MEDIA ADD
useradd -d /home/media family &&
chown -R family:family /home/media &&
passwd family


## NOTIF
echo "
1. config cmdline 01-boot.conf
2. config /etc/crypttab
3. add complement userneed
4. generate initramfs
"
