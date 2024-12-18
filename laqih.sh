#!/bin/bash

#=======================================================================#
# Copyright (C) 2024 Mehmet Sensoy <mehmetsensoyme@gmail.com>           #
#                                                                       #
# This file is part of LAQIH - LinuxCNC and QtPyVCP Installation Helper #
# https://github.com/mehmetsensoyme/LAQIH                               #
#                                                                       #
# This file may be distributed under the terms of the GNU GPLv3 license #
#=======================================================================#

# Clear the terminal
clear
echo -e "\e[0m\c"

# Initial Screen
echo "#######################################################";
echo "# V0.1                                                #";
echo "#                                                     #";
echo "#                                                     #";
echo "#   ___       ________  ________  ___  ___  ___       #";
echo "#  |\  \     |\   __  \|\   __  \|\  \|\  \|\  \      #";
echo "#  \ \  \    \ \  \|\  \ \  \|\  \ \  \ \  \\\  \     #";
echo "#   \ \  \    \ \   __  \ \  \\\  \ \  \ \   __  \    #";
echo "#    \ \  \____\ \  \ \  \ \  \\\  \ \  \ \  \ \  \   #";
echo "#     \ \_______\ \__\ \__\ \_____  \ \__\ \__\ \__\  #";
echo "#      \|_______|\|__|\|__|\|___| \__\|__|\|__|\|__|  #";
echo "#                                \|__|                #";
echo "#                                                     #";
echo "#                                                     #";
echo "#      LinuxCNC and QtPyVCP Installation Helper       #";
echo "#######################################################";

#=======================================================================#
# Automatic Time Setup - NTP Installation and Configuration
#=======================================================================#
echo -e "\nStarting NTP installation...\n"
sudo apt-get install ntp -y
sudo systemctl start ntp
sudo systemctl enable ntp
sudo systemctl restart ntp
echo -e "NTP installation and configuration completed!"
sleep 10

#=======================================================================#
# GPG Key Fetching and RT Kernel Installation
#=======================================================================#
echo -e "\nFetching signing key...\n"
GPGTMP=$(mktemp -d /tmp/.gnupgXXXXXX)
sudo gpg --homedir $GPGTMP --keyserver hkp://keyserver.ubuntu.com --recv-key 3cb9fd148f374fef
sudo gpg --homedir $GPGTMP --export 'EMC Archive Signing Key' | sudo tee /usr/share/keyrings/linuxcnc.gpg > /dev/null
rm -rf $GPGTMP

echo -e "\nInstalling RT Kernel...\n"
sudo apt install -y linux-image-rt-amd64 linux-headers-rt-amd64 grub-customizer
echo -e "RT Kernel installed...\n"

#=======================================================================#
# GRUB Configuration
#=======================================================================#
echo -e "\nConfiguring GRUB..."
cp /etc/default/grub /etc/default/grub.bak
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_HIDDEN_TIMEOUT=0/GRUB_HIDDEN_TIMEOUT=1/' /etc/default/grub
update-grub
echo -e "GRUB configuration completed.\n"

#=======================================================================#
# LinuxCNC and MESA Installation
#=======================================================================#
echo 'Installing LinuxCNC and Mesaflash...'
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/linuxcnc.gpg] https://www.linuxcnc.org/ bookworm base 2.9-uspace 2.9-rt" | sudo tee /etc/apt/sources.list.d/linuxcnc.list > /dev/null
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y linuxcnc-uspace linuxcnc-uspace-dev mesaflash
sudo apt autoremove -y
echo -e "LinuxCNC and Mesaflash installed...\n"

#=======================================================================#
# QtPyVCP Installation
#=======================================================================#
echo -e "\nAdding QtPyVCP repository..."
echo 'deb [arch=amd64] https://repository.qtpyvcp.com/apt develop main' | sudo tee /etc/apt/sources.list.d/kcjengr.list > /dev/null
curl -sS https://repository.qtpyvcp.com/repo/kcjengr.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/kcjengr.gpg > /dev/null
gpg --keyserver keys.openpgp.org --recv-key 2DEC041F290DF85A
sudo apt-get update && sudo apt-get upgrade -y
echo -e "QtPyVCP repository added and system upgrade completed...\n"

#=======================================================================#
# Install QtPyVCP and Required Dependencies
#=======================================================================#
echo -e "Installing QtPyVCP...\n"
sudo apt-get install -y python3-qtpyvcp
echo -e "QtPyVCP installed...\n"

echo -e "Installing necessary dependencies...\n"
sudo apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget curl libbz2-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools gstreamer1.0-tools espeak espeak-ng sound-theme-freedesktop python3-opengl python3-pyqt5 python3-pyqt5.qsci python3-pyqt5.qtsvg python3-pyqt5.qtopengl python3-opencv python3-dbus python3-dbus.mainloop.pyqt5 python3-espeak python3-pyqt5.qtwebengine python3-xlib python3-numpy python3-cairo python3-gi-cairo python3-poppler-qt5 pyqt5-dev-tools qttools5-dev qttools5-dev-tools libpython3-dev
echo -e "Necessary dependencies installed...\n"

#=======================================================================#
# Python Virtual Environment (venv) Installation
#=======================================================================#
echo -e "Installing Python3.11 venv package...\n"
sudo apt install -y python3.11-venv
echo -e "Venv installed...\n"

echo -e "Creating virtual environment (venv)...\n"
python3 -m venv ~/venv
source ~/venv/bin/activate
echo -e "Installing Hiyapyco package...\n"
pip install hiyapyco
deactivate
echo -e "Virtual environment (venv) successfully created, Hiyapyco package installed, and deactivated...\n"

#=======================================================================#
# Switching to Xorg and GDM Configuration
#=======================================================================#
echo -e "Switching to Xorg/X11...\n"
sudo cp /etc/gdm3/daemon.conf /etc/gdm3/daemon.conf.bak
echo "[daemon]" | sudo tee -a /etc/gdm3/daemon.conf
echo "WaylandEnable=false" | sudo tee -a /etc/gdm3/daemon.conf
echo -e "Switched to Xorg/X11...\n"

#=======================================================================#
# APScheduler Installation
#=======================================================================#
echo -e "Downloading APScheduler...\n"
wget https://files.pythonhosted.org/packages/5e/34/5dcb368cf89f93132d9a31bd3747962a9dc874480e54333b0c09fa7d56ac/APScheduler-3.10.4.tar.gz
tar xzf APScheduler-3.10.4.tar.gz
cd APScheduler-3.10.4/
echo -e "Installing APScheduler...\n"
sudo python3 setup.py install
cd ..
sudo rm -r APScheduler-3.10.4.tar.gz && sudo rm -r APScheduler-3.10.4
echo -e "APScheduler installed...\n"

#=======================================================================#
# Presenting options to the user
#=======================================================================#
echo -e "1 - Restart Gnome\n"
echo -e "2 - Complete installation and exit\n"
read -p "Enter your choice (1 or 2): " choice

# Perform actions based on user input
if [ "$choice" -eq 1 ]; then
    echo -e "Restarting Gnome...\n"
    sudo systemctl restart gdm
    echo -e "Gnome restarted...\n"
elif [ "$choice" -eq 2 ]; then
    echo -e "Completing the installation...\n"
    echo -e "Installation completed.\n"
else
    echo -e "Invalid choice entered.\n"
fi

#=======================================================================#
# Final message to keep terminal open
#=======================================================================#
echo -e "Process completed, terminal will remain open.\n"
