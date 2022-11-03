#!/bin/bash

echo "running apt update"
apt-get update
echo "install ansible"
apt-get install ansible -y
echo "install python3-pip"
apt-get install python3-pip -y
echo "install pywinrm"
pip install "pywinrm[credssp]"
echo "install cryptography"
pip install -U cryptography

