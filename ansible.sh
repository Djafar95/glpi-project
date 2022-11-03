#!/bin/bash

#####################################################
###                PRE CONFIGURATION              ###
#####################################################
#Configure logging
path_log='/var/log/ansible_install/install.log'

#Set timezone
echo "`date` Starting to set the timezone" >> $path_log
sudo timedatectl set-timezone Europe/Paris
echo "`date` The set of the timezone is completed" >> $path_log


#running apt update
echo "`date` running apt update..." >> $path_log
sudo apt-get update
sleep 60
echo "`date` apt update is completed" >> $path_log


#install ansible
echo "`date` Installing ansible ..." >> $path_log
apt-get install ansible -y
sleep 60
echo "`date` ansible is installed" >> $path_log


#install python3
echo "`date` Installing python ..." >> $path_log
apt-get install python3-pip -y
sleep 60
echo "`date` python is installed" >> $path_log


#install pywinrm
echo "`date` Installing pywinrm ..." >> $path_log
pip install "pywinrm[credssp]"
sleep 60
echo "`date` pywinrm is installed" >> $path_log


#install cryptography
echo "`date` Installing cryptography ..." >> $path_log
pip install -U cryptography
sleep 60
echo "`date` cryptography is installed" >> $path_log
