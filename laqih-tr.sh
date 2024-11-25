#!/bin/bash

#=======================================================================#
# Copyright (C) 2024 Mehmet Sensoy <mehmetsensoyme@gmail.com>           #
#                                                                       #
# This file is part of LAQIH - LinuxCNC and QtPyVCP Installation Helper #
# https://github.com/mehmetsensoyme/LAQIH                               #
#                                                                       #
# This file may be distributed under the terms of the GNU GPLv3 license #
#=======================================================================#

#Terminal'i temizliyor.
clear
echo -e "\e[0m\c"

#Temizledikten sonra çıkan ekran
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
# Otomatik Zaman Ayarlayıcı - NTP Kurulum ve Konfigürasyon
#=======================================================================#
echo -e "\nNTP kurulumu başlıyor...\n"
sudo apt-get install ntp -y
sudo systemctl start ntp
sudo systemctl enable ntp
sudo systemctl restart ntp
echo "NTP kurulumu ve yapılandırması tamamlandı!"
sleep 10

#=======================================================================#
# İmzalama Anahtarı ve RT Kernel Kurulumu
#=======================================================================#
GPGTMP=$(mktemp -d /tmp/.gnupgXXXXXX)
sudo gpg --homedir $GPGTMP --keyserver hkp://keyserver.ubuntu.com --recv-key 3cb9fd148f374fef
sudo gpg --homedir $GPGTMP --export 'EMC Archive Signing Key' | sudo tee /usr/share/keyrings/linuxcnc.gpg > /dev/null
rm -rf $GPGTMP

echo -e '\nRT Kernel kuruluyor...\n'
sudo apt install -y linux-image-rt-amd64 linux-headers-rt-amd64 grub-customizer
echo -e '\nRT Kernel kuruldu...\n'

#=======================================================================#
# GRUB Konfigürasyonu
#=======================================================================#
echo -e "\nGRUB yapılandırması düzenleniyor..."
cp /etc/default/grub /etc/default/grub.bak
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_HIDDEN_TIMEOUT=0/GRUB_HIDDEN_TIMEOUT=1/' /etc/default/grub
update-grub
echo -e "\nGRUB yapılandırması tamamlandı.\n"

#=======================================================================#
# LinuxCNC ve MESA Kurulumu
#=======================================================================#
echo 'Apt repolarına LinuxCNC ekleniyor...'
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/linuxcnc.gpg] https://www.linuxcnc.org/ bookworm base 2.9-uspace 2.9-rt" | sudo tee /etc/apt/sources.list.d/linuxcnc.list > /dev/null
sudo apt-get update && sudo apt upgrade -y
sudo apt-get install -y linuxcnc-uspace linuxcnc-uspace-dev mesaflash
sudo apt autoremove -y
echo -e '\nLinuxCNC ve Mesaflash kuruldu...\n'

#=======================================================================#
# QtPyVCP ve Gerekliliklerin Kurulması
#=======================================================================#
echo -e "\nQtPyVCP repository'si ekleniyor..."
echo 'deb [arch=amd64] https://repository.qtpyvcp.com/apt develop main' | sudo tee /etc/apt/sources.list.d/kcjengr.list > /dev/null
curl -sS https://repository.qtpyvcp.com/repo/kcjengr.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/kcjengr.gpg > /dev/null
gpg --keyserver keys.openpgp.org --recv-key 2DEC041F290DF85A
echo " "
sudo apt-get update && sudo apt upgrade -y
sudo apt-get install -y python3-qtpyvcp
sudo apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget curl libbz2-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools gstreamer1.0-tools espeak espeak-ng sound-theme-freedesktop python3-opengl python3-pyqt5 python3-pyqt5.qsci python3-pyqt5.qtsvg python3-pyqt5.qtopengl python3-opencv python3-dbus python3-dbus.mainloop.pyqt5 python3-espeak python3-pyqt5.qtwebengine python3-xlib python3-numpy python3-cairo python3-gi-cairo python3-poppler-qt5 pyqt5-dev-tools qttools5-dev qttools5-dev-tools libpython3-dev
echo -e "\nQtPyVCP ve Gerekli Bağlılıklar Kuruldu...\n"

#=======================================================================#
# Python Virtual Environment (venv) Kurulumu
#=======================================================================#
echo -e "Python3.11 venv paketini kuruyoruz...\n"
sudo apt install -y python3.11-venv
echo -e "Virtual environment (venv) oluşturuluyor...\n"
python3 -m venv ~/venv
echo -e "\nVirtual environment (venv) etkinleştiriliyor...\n"
source ~/venv/bin/activate
echo -e "\nHiyapyco paketi kuruluyor...\n"
pip install hiyapyco
echo -e "\nVirtual environment (venv) ortamından çıkılıyor...\n"
deactivate
echo -e "Virtual environment (venv) başarıyla kuruldu, hiyapyco paketi yüklendi ve ortamdan çıkıldı...\n"

#=======================================================================#
# Xorg'a geçiş ve GDM Konfigürasyonu
#=======================================================================#
echo -e "Xorg/X11'e geçiliyor...\n"
sudo cp /etc/gdm3/daemon.conf /etc/gdm3/daemon.conf.bak
echo "[daemon]" | sudo tee -a /etc/gdm3/daemon.conf
echo "WaylandEnable=false" | sudo tee -a /etc/gdm3/daemon.conf
echo -e "Xorg/X11'e geçildi...\n"

#=======================================================================#
# APScheduler Kurulumu
#=======================================================================#
echo -e "APScheduler İndiriliyor...\n"
wget https://files.pythonhosted.org/packages/5e/34/5dcb368cf89f93132d9a31bd3747962a9dc874480e54333b0c09fa7d56ac/APScheduler-3.10.4.tar.gz
tar xzf APScheduler-3.10.4.tar.gz
cd APScheduler-3.10.4/
echo -e "APScheduler Kuruluyor...\n"
sudo python3 setup.py install
cd ..
sudo rm -r APScheduler-3.10.4.tar.gz && sudo rm -r APScheduler-3.10.4
echo -e "APScheduler Kuruldu...\n"

#=======================================================================#
# GDM başlatılsın mı başlatılmasın mı seçeneği sunmak
#=======================================================================#
echo -e "1 - Gnome'u yeniden başlat\n"
echo -e "2 - Kurulumu tamamla ve çık\n"
read -p "Bir seçenek girin (1 veya 2): " secim

# Kullanıcının seçimine göre işlem yapın
if [ "$secim" -eq 1 ]; then
    echo -e "Gnome yeniden başlatılıyor...\n"
    sudo systemctl restart gdm
    echo -e "Yeniden başlatıldı...\n"
elif [ "$secim" -eq 2 ]; then
    echo -e "Kurulum tamamlanıyor...\n"
    # Kurulumu tamamlama işlemleri burada yapılabilir
    echo -e "Kurulum tamamlandı.\n"
else
    # Geçersiz giriş
    echo -e "Geçersiz bir seçenek girdiniz.\n"
fi

#=======================================================================#
# Terminali kapatmamak için son bir mesaj veya işlem
#=======================================================================#
echo -e "İşlem tamamlandı, terminal açık kalacak.\n"