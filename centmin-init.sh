#!/bin/sh
yum -y --exclude=kernel* update
yum -y install git bc

# Change passwords, add new dummy root user, and switch authorized Digital Ocean SSH key to new root user
echo "Change the root password. You will have to enter this password if you ever want to switch your user to the root user using the su command."
passwd
read -p 'Enter a user name for yourself. To gain root access, you will have to login with your Digital Ocean SSH key as this user and then switch to the root user using the su command using the previously entered password. IMPORTANT: From now on, any IP address that attempts to log in through SSH as the root user will be banned. Enter your root users login name: ' ROOT_LOGIN_NAME
adduser $ROOT_LOGIN_NAME
echo "Now enter a password for the new root user."
passwd $ROOT_LOGIN_NAME
mkdir /home/$ROOT_LOGIN_NAME/.ssh
cp /root/.ssh/authorized_keys /home/$ROOT_LOGIN_NAME/.ssh/authorized_keys
rm ~/.ssh/authorized_keys
chown $ROOT_LOGIN_NAME:$ROOT_LOGIN_NAME /home/$ROOT_LOGIN_NAME/.ssh
chmod 700 /home/$ROOT_LOGIN_NAME/.ssh
chown $ROOT_LOGIN_NAME:$ROOT_LOGIN_NAME /home/$ROOT_LOGIN_NAME/.ssh/authorized_keys
chmod 600 /home/$ROOT_LOGIN_NAME/.ssh/authorized_keys

# Tweak SSH settings for added security benefit
perl -pi -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# This probably doesn't do anything because it's supposedly just for SSH1 but let's change it anyway.
perl -pi -e 's/#ServerKeyBits 1024/ServerKeyBits 2048/g' /etc/ssh/sshd_config
perl -pi -e 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
perl -pi -e 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
# Change port number perl -pi -e 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
echo "AllowUsers $ROOT_LOGIN_NAME" >> /etc/ssh/sshd_config

# Download and set up CentminMod
cd /usr/local/src
wget http://centminmod.com/download/centmin-v1.2.3-eva2000.04.zip
unzip centmin-v1.2.3-eva2000.04.zip
cd centmin-v1.2.3mod
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' /usr/local/src/centmin-v1.2.3mod/centmin.sh
perl -pi -e 's/Brisbane/New_York/g' /usr/local/src/centmin-v1.2.3mod/centmin.sh
perl -pi -e 's/nginx centminmod/Powered by Poor.IO/g' /usr/local/src/centmin-v1.2.3mod/centmin.sh
chmod +x centmin.sh

# Run CentminMod and automatically select fresh install
./centmin.sh
