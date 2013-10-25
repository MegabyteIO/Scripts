#!/bin/sh
# First change root password and add new user, in this case "bernard" (i.e. passwd, then adduser bernard)
mkdir /home/bernard/.ssh
cp /root/.ssh/authorized_keys /home/bernard/.ssh/authorized_keys
rm ~/.ssh/authorized_keys
chown bernard:bernard /home/bernard/.ssh
chmod 700 /home/bernard/.ssh
chown bernard:bernard /home/bernard/.ssh/authorized_keys
chmod 600 /home/bernard/.ssh/authorized_keys
# Hit "Install Package Maintainer's Version" twice if the screen pops up
aptitude update && aptitude dist-upgrade -y
# Changing the port # is totally unnecessary - the only protection it gives is slight security
# through obfuscation and maybe it helps keep your logs clean. Not worth it.
# perl -pi -e 's/Port 22/Port 8388/g' /etc/ssh/sshd_config
perl -pi -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# This probably doesn't do anything because it's supposedly just for SSH1 but let's change it anyway.
perl -pi -e 's/ServerKeyBits 768/ServerKeyBits 2048/g' /etc/ssh/sshd_config
perl -pi -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "AllowUsers bernard" >> /etc/ssh/sshd_config
# Begin adding OpenVPN
cd /usr/local/src
wget http://swupdate.openvpn.org/as/openvpn-as-2.0-Ubuntu12.i386.deb
dpkg -i openvpn-as-2.0-Ubuntu12.i386.deb
rm openvpn-as-2.0-Ubuntu12.i386.deb
passwd openvpn
# shows IP address
#/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
apt-get install denyhosts
rm /etc/resolv.conf
echo "nameserver 208.67.222.222" >> /etc/resolv.conf
echo "nameserver 208.67.220.220" >> /etc/resolv.conf
# The following will probably give you a lot of nothing. But for the paranoid, adjust accordingly.
#perl -pi -e 's/ADMIN_EMAIL = root@localhost/ADMIN_EMAIL = youremail@yourprovider.com/g' /etc/denyhosts.conf
# Update to your time zone
dpkg-reconfigure tzdata
# change host name to IP/use alias for other?
reboot