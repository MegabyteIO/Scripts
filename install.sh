#!/bin/sh
# TODOS: Change shell permissions after execution

# Updates all software except the kernel
yum -y --exclude=kernel* update
# Installs some dependencies
yum -y install git bc

# Directory where centmin is installed
CENTMIN_DIR="usr/local/src"
# Folder name for the scripts, stored next to the centminmod directory in CENTMINDIR
INSTALL_FOLDER_NAME="Scripts"
# Following folders are names of folders in PoorIO directory
CONF_FOLDER="files" # Configuration files
SCRIPTS_FOLDER="files" # Shell scripts
WORDPRESS_FOLDER="files" # WordPress supplements
SSH_PORT_NUMBER=8388
CENTMIN_FOLDER_NAME="centmin-v1.2.3mod"
CENTMIN_DOWNLOAD_URL="http://centminmod.com/download/centmin-v1.2.3-eva2000.04.zip"
CENTMIN_FILE_NAME="centmin-v1.2.3-eva2000.04.zip"
GITHUB_URL="https://github.com/bzizzle/Scripts.git"
# Change root user password
passwd

# Download sources
cd /$CENTMIN_DIR
git clone $GITHUB_URL

# Set up new root username and password
if [ $(id -u) -eq 0 ]; then
	read -p "Enter a new root username: " NEW_ROOT_USERNAME
	read -s -p "Enter the new root users password: " NEW_ROOT_PASSWORD
	egrep "^$NEW_ROOT_USERNAME" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$NEW_ROOT_USERNAME already exists!"
		exit 1
	else
		ENCRYPTED_NEW_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $NEW_ROOT_PASSWORD)
		useradd -m -p $ENCRYPTED_NEW_ROOT_PASSWORD $NEW_ROOT_USERNAME
		[ $? -eq 0 ] && echo "$NEW_ROOT_USERNAME has been added to the user list." || echo "Failed to add $NEW_ROOT_USERNAME to the user list."
	fi
else
	echo "You must be root to add a user to the system."
	exit 2
fi

# Add new root user to visudo list
cd /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER
chmod +x visudo.sh
./visudo.sh $NEW_ROOT_USERNAME
chmod 644 visudo.sh

# Change the SSH key to be used with new root user
read -p "Is this a Digital Ocean droplet created using an SSH key (y/n)?" SSH_CHOICE
case "$SSH_CHOICE" in 
  y|Y ) echo "yes";;
  n|N ) echo "no";;
  * ) echo "Invalid input.";;
esac

# Transfer SSH key credentials from root to new root user
if [ "$SSH_CHOICE" == "yes" ]; then
  echo "Moving SSH key credentials from root user to new root user. The root user will no longer be able to connect via SSH."
  cp /root/.ssh/authorized_keys /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
  rm ~/.ssh/authorized_keys
  chown $NEW_ROOT_USERNAME:$NEW_ROOT_USERNAME /home/$NEW_ROOT_USERNAME/.ssh
  chmod 700 /home/$NEW_ROOT_USERNAME/.ssh
  chown $NEW_ROOT_USERNAME:$NEW_ROOT_USERNAME /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
  chmod 600 /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
fi

# Tweak SSH settings for security
# Let CentminMod handle the changing of the port number so that there are no conflicts with the firewall
# perl -pi -e 's/#Port 22/Port $SSH_PORT_NUMBER/g' /etc/ssh/sshd_config
perl -pi -e 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
perl -pi -e 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "AllowUsers $NEW_ROOT_USERNAME" >> /etc/ssh/sshd_config

# Settings for SSH key login
if [ "$SSH_CHOICE" == "yes" ]; then
  perl -pi -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  # This probably doesn't do anything because it's supposedly just for SSH1 but let's change it anyway.
  perl -pi -e 's/#ServerKeyBits 1024/ServerKeyBits 2048/g' /etc/ssh/sshd_config
fi

# Download and set up CentminMod
cd /$CENTMIN_DIR
wget $CENTMIN_DOWNLOAD_URL
unzip $CENTMIN_FILE_NAME
rm -f $CENTMIN_FILE_NAME
cd $CENTMIN_FOLDER_NAME

# Change time zone
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
perl -pi -e 's/Brisbane/New_York/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
perl -pi -e 's/nginx centminmod/Powered by Poor.IO/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
chmod +x centmin.sh

# Change SSH port
perl -pi -e 's/^read -ep "Enter option [ 1 - 21 ] " option$/^option=sshdport$/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
#Enter existing SSH port number (default = 22 for fresh installs):   22
#Enter the SSH port number you want to change to: $SSH_PORT_NUMBER
./centmin.sh
perl -pi -e 's/^option=sshdport$/^read -ep "Enter option [ 1 - 21 ] " option$/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Run a fresh Centmin install
perl -pi -e 's/^read -ep "Enter option [ 1 - 21 ] " option$/^option=install$/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
./centmin.sh
perl -pi -e 's/^option=install$/^read -ep "Enter option [ 1 - 21 ] " option$/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
