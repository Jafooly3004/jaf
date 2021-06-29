#!/bin/bash

[[ $EUID -ne 0 ]] && echo "This script must be run as root." && exit 1

#DEBIAN / UBUNTU
#sudo apt-get update
#sudo apt-get install zenity -y
#sudo apt-get install python -y


#REDHAT
#dnf install zenity
#dnf install python

#ARCH
#pacman -S zenity
#pacman -S python

sudo chmod 777 /jaf
sudo chmod +x jaf.sh
sudo cp jaf.sh /usr/local/bin/jaf.sh
