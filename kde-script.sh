#!/bin/bash

set -euo pipefail

# Help message
usage="$0 [-h] [-v] [-f] -- script to setup my KDE Plasma setup

Available options:
	-h	help message
	-f	rewrite files/directories if they already exist"


# Get arguments
while getopts "hf" opt; do
	case "$opt" in
		h) echo "$usage" ; exit 0 ;;
		f) force_flag=true ;;
		\?) echo "Invalid option"; exit 1 ;;
	esac
done

# Check if alacritty config already exists
if [[ -d "$HOME/.config/alacritty" ]]; then
	if [[ "$force_flag" = true ]]; then;
		rm -rf "$HOME/.config/alacritty";
		continue
	fi
	echo "[ERROR] $HOME/.config/alacritty is already here. Use -f option to rewrite directory";
	exit 1;
fi
# Remove alacritty config directory
rm -rf "$HOME/.config/alacritty"

# Create alacritty config directory and change working directory to it
mkdir "$HOME/.config/alacritty"
cd "$HOME/.config/alacritty"

# Fetch hyper alacritty theme and save it to alacritty.toml
curl -o alacritty.toml https://raw.githubusercontent.com/alacritty/alacritty-theme/refs/heads/master/themes/hyper.toml

# Add window, scrolling, and font configuration to alacritty.toml
echo "

[window]
padding = { x = 2, y = 2}
opacity = 0.7
blur = true

[scrolling]
multiplier = 1

[font]
normal = { family = "EnvyCodeR Nerd Font Mono", style = "Regular" }
bold = { family = "EnvyCodeR Nerd Font Mono", style = "Bold" }
italic = { family = "EnvyCodeR Nerd Font Mono", style = "Italic" }
size = 11

" >> alacritty.toml

# Install all system utilities
sudo pacman -S --needed --noconfirm bash-completion power-profiles-daemon wl-clipboard zbar zip unzip unrar \
fastfetch wget dust htop man-db grub-btrfs cronie gvfs timeshift phonon-qt6-vlc nano nano-syntax-highlighting bluez bluez-utils bat

# Install development utilities
sudo pacman -S --needed --noconfirm linux-headers gcc clang make cmake git

# Install NVIDIA drivers and utilities
sudo pacman -S --needed --noconfirm nvidia-open nvidia-utils lib32-nvidia-utils libva-nvidia-driver opencl-nvidia nvtop \
nvidia-settings nvidia-prime

# Install fonts
sudo pacman -S --needed --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk \
ttf-fira-sans ttf-fira-mono ttf-envycoder-nerd

# Install KDE Plasma
sudo pacman -S --needed --noconfirm plasma-desktop bluedevil kscreen plasma-nm plasma-pa breeze breeze-gtk \
kde-cli-tools kde-gtk-config kdecoration kdeplasma-addons kgamma kglobalacceld kinfocenter \
kmenuedit kpipewire kscreenlocker ksystemstats kwayland plasma-browser-integration plasma-disks \
plasma-integration plasma-systemmonitor plasma-thunderbolt plasma-workspace polkit-kde-agent \
print-manager spectacle systemsettings xdg-desktop-portal-kde

# Install Dolphin file manager with plugins
sudo pacman -S --needed --noconfirm dolphin dolphin-plugins kio-admin ffmpegthumbs icoutils kdegraphics-thumbnailers \
kimageformats libappimage qt6-imageformats taglib

# Install Ark archiver with plugins
sudo pacman -S --needed --noconfirm ark 7zip unrar unarchiver

# Install multimedia programs
sudo pacman -S --needed --noconfirm partitionmanager okular gwenview kate ffmpeg vlc alacritty qbittorrent

# Install LibreOffice with plugins
sudo pacman -S --needed --noconfirm libreoffice-fresh hunspell hunspell-en_us hunspell-ru hyphen hyphen-en libmythes mythes-en

# Install other programs
sudo pacman -S --needed --noconfirm steam telegram-desktop obs-studio snes9x-gtk proton-vpn-gtk-app

# Install SDDM
sudo pacman -S --needed --noconfirm sddm sddm-kcm qt5-declarative

# Disable generating -debug package in PKGBUILD script
sudo sed -i '/^OPTIONS=/s/debug/!debug/' /etc/makepkg.conf

# Add fancy look for Pacman
sudo sed -i '/^\[options\]/a Color\nILoveCandy\nVerbosePkgLists' /etc/pacman.conf

# Build and install paru AUR helper
cd
git clone https://aur.archlinux.org/paru-bin.git
cd paru
makepkg -si --noconfirm
cd
rm -rf paru
sudo pacman -Rns --noconfirm rust

# Enable RemoveMake option in paru config
sudo sed -i 's/^#RemoveMake/RemoveMake/' /etc/paru.conf

# Install AUR packages
paru -S --noconfirm --skipreviewkde-thumbnailer-apk raw-thumbnailer zen-browser-bin spotify \
vesktop-bin zoom obs-backgroundremoval cmatrix-neo-git ttf-ms-fonts \
downgrade vscodium-bin r2modman-bin

# Disable headset autoswitch
sudo sed -i '/bluetooth\.autoswitch-to-headset-profile/,/}/{s/\(default *= *\)false/\1true/}' /usr/share/wireplumber/wireplumber.conf
systemctl --user restart wireplumber.service

# Edit nanorc
echo "bind ^F whereis all" | sudo tee -a /etc/nanorc > /dev/null
echo "bind ^G findnext all" | sudo tee -a /etc/nanorc > /dev/null
echo "bind ^D findprevious all" | sudo tee -a /etc/nanorc > /dev/null
echo "bind ^Z undo main" | sudo tee -a /etc/nanorc > /dev/null
echo "bind ^Y redo main" | sudo tee -a /etc/nanorc > /dev/null
echo "set tabsize 4" | sudo tee -a /etc/nanorc > /dev/null
echo "set linenumbers" | sudo tee -a /etc/nanorc > /dev/null
echo "set mouse" | sudo tee -a /etc/nanorc > /dev/null
echo "set colonparsing" | sudo tee -a /etc/nanorc > /dev/null
echo "set nohelp" | sudo tee -a /etc/nanorc > /dev/null
echo "set tabstospaces" | sudo tee -a /etc/nanorc > /dev/null
echo "include \"/usr/share/nano/*.nanorc\"" | sudo tee -a /etc/nanorc > /dev/null
echo "include \"/usr/share/nano/extra/*.nanorc\"" | sudo tee -a /etc/nanorc > /dev/null
echo "include \"/usr/share/nano-syntax-highlighting/*.nanorc\"" | sudo tee -a /etc/nanorc > /dev/null

# Enable bluetooth
sudo systemctl enable bluetooth.service

# Enable SDDM
sudo systemctl enable sddm.service

# Ask user to reboot
read -rp "Setup complete. Reboot now? (y/n):" yn
case $yn in
	[Yy]*) reboot ;;
	*) echo "Please reboot manually later." ;;
esac
