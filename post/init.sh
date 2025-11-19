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

LVMDRIVER=""

if [[ ! -z $(vgs) ]]; then
    LVMDRIVER="lvm2"
fi


## DIRECTO

mkdir /opt/flat &&
ln -sf /opt/flat /var/lib/flatpak &&


## INSTALL
pacman -Syy --noconfirm &&
pacman -S wireless-regdb \
    amd-ucode \
    mkinitcpio \
    base-devel \
    lvm2 \
    mesa \
    kitty \
    lib32-mesa \
    vulkan-radeon \
    lib32-vulkan-radeon \
    sof-firmware \
    linux-firmware-atheros \
    linux-firmware-intel \
    linux-firmware-other \
    linux-firmware-realtek \
    linux-firmware-amdgpu \
    linux-firmware-radeon \
    openssh \
    firewalld \
    bluez-utils \
    dnsmasq \
    networkmanager \
    gamescope \
    gamemode \
    xorg-server \
    pipewire \
    lib32-pipewire \
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    ttf-droid \
    kitty-terminfo \
    git \
    wget \
    unzip \
    flatpak \
    discover \
    fuse \
    umu-launcher \
    btop \
    lightdm \
    lightdm-webkit2-greeter \
    steam \
    kodi-gles \
    dolphin-emu \
    firefox \
    kwallet \
    plasma-nm \
    ksshaskpass \
    kwallet-pam \
    plasma-desktop \
    kwalletmanager \
    aria2 --noconfirm &&


curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash &&

## CLEANS
rm /usr/share/wayland-sessions/kodi-gbm.desktop &&
rm /usr/share/xsessions/kodi.desktop &&


## CONFIG
cp -fr /post/base/* / &&
cp -fr /post/extra/amd/* / &&


## LOCALE
locale-gen &&


##
## EMULATOR

## android
# pacman -S waydroid
# waydroid init -s GAPPS &&


## switch
wget -O /usr/pbin/switch.AppImage https://git.ryujinx.app/api/v4/projects/1/packages/generic/Ryubing/1.3.3/ryujinx-1.3.3-x64.AppImage &&
chmod +x /usr/pbin/switch.AppImage && 


## heroic
wget -O /usr/pbin/heroic.AppImage https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/v2.18.1/Heroic-2.18.1-linux-x86_64.AppImage &&
chmod +x /usr/pbin/heroic.AppImage  &&


## playstation 1
wget -O /usr/pbin/plays1.AppImage https://github.com/stenzek/duckstation/releases/download/latest/DuckStation-x64.AppImage &&
chmod +x /usr/pbin/plays1.AppImage &&


## playstation 2
wget -O /usr/pbin/plays2.AppImage https://github.com/PCSX2/pcsx2/releases/download/v2.4.0/pcsx2-v2.4.0-linux-appimage-x64-Qt.AppImage &&
chmod +x /usr/pbin/plays2.AppImage &&


## playstation 3
wget -O /usr/pbin/plays3.AppImage https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-c669a0beb721d704241980675154cb35b0221d92/rpcs3-v0.0.38-18364-c669a0be_linux64.AppImage &&
chmod +x /usr/pbin/plays3.AppImage &&


## xbox 360
wget -O /usr/pbin/xbox36.AppImage https://github.com/xemu-project/xemu/releases/download/v0.8.115/xemu-v0.8.115-x86_64.AppImage &&
chmod +x /usr/pbin/xbox36.AppImage && 


##
## FIRMWARE

## playstation 3
mkdir -p /var/games/bios/plays3 &&
wget -P /var/games/bios/plays3 https://archive.org/download/ps3-official-firmwares/Firmware%204.89/PS3UPDAT.PUP


## switch
mkdir -p /var/games/bios/switch &&
wget -P /var/games/bios/switch https://github.com/THZoria/NX_Firmware/releases/download/20.5.0/Firmware.20.5.0.zip
cd /var/games/bios/switch &&
unzip Firmware.20.5.0.zip &&
cd /


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


## ADMIN ADD
useradd -d /var/lib/telnet -u 23 net &&
usermod -aG wheel net &&
chown -R net:net /var/lib/telnet &&
passwd net

## LUKSDISK
echo "rd.luks.name=$(blkid -s UUID -o value $DISKPROC)=root root=/dev/proc/root" > /etc/cmdline.d/01-boot.conf &&
echo "data UUID=$(blkid -s UUID -o value $DISKDATA) none" >> /etc/crypttab 
mkinitcpio -P

## NOTIF
echo "
1. config cmdline 01-boot.conf
2. config /etc/crypttab
3. add complement userneed
4. generate initramfs
"
