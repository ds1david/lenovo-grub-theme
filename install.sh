#! /usr/bin/env bash

THEME='lenovo-grub-theme'

# Pre-authorise sudo
sudo echo

GRUB_DIR='grub'
UPDATE_GRUB='update-grub'

echo 'Fetching theme archive'
wget https://github.com/ds1david/${THEME}/archive/master.zip

echo 'Unpacking theme'
unzip master.zip

echo 'Creating GRUB themes directory'
sudo mkdir -p /boot/${GRUB_DIR}/themes/${THEME}

echo 'Copying theme to GRUB themes directory'
sudo cp -r ${THEME}-master/* /boot/${GRUB_DIR}/themes/${THEME}

echo 'Removing other themes from GRUB config'
sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub

echo 'Making sure GRUB uses graphical output'
sudo sed -i 's/^\(GRUB_TERMINAL\w*=.*\)/#\1/' /etc/default/grub

echo 'Removing empty lines at the end of GRUB config' # optional
sudo sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' /etc/default/grub
udo
echo 'Adding new line to GRUB config just in case' # optional
echo | sudo tee -a /etc/default/grub

echo 'Adding theme to GRUB config'
echo "GRUB_THEME=/boot/${GRUB_DIR}/themes/${THEME}/theme.txt" | sudo tee -a /etc/default/grub

echo 'Removing theme installation files'
rm -rf master.zip ${THEME}-master

if [ -e /usr/share/plymouth/themes/default.grub ]; then
    echo 'Removing blink purple screen'
    sudo cat << '    EOF' >> /usr/share/plymouth/themes/ubuntu-logo/ubuntu-logo.grub
    if background_color 0,0,0; then
      clear
    fi
    EOF
fi

echo 'Updating GRUB'
eval sudo "$UPDATE_GRUB"
