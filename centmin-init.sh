#!/bin/sh
yum -y --exclude=kernel* update
yum -y install git bc
passwd
#adduser bernard
#passwd bernard
#mkdir /home/bernard/.ssh
#cp /root/.ssh/authorized_keys /home/bernard/.ssh/authorized_keys
#rm ~/.ssh/authorized_keys
#chown bernard:bernard /home/bernard/.ssh
#chmod 700 /home/bernard/.ssh
#chown bernard:bernard /home/bernard/.ssh/authorized_keys
#chmod 600 /home/bernard/.ssh/authorized_keys
perl -pi -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# This probably doesn't do anything because it's supposedly just for SSH1 but let's change it anyway.
perl -pi -e 's/#ServerKeyBits 1024/ServerKeyBits 2048/g' /etc/ssh/sshd_config
perl -pi -e 's/#PermitRootLogin yes/PermitRootLogin without-password/g' /etc/ssh/sshd_config
perl -pi -e 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
#echo "AllowUsers bernard" >> /etc/ssh/sshd_config
cd /usr/local/src
wget http://centminmod.com/download/centmin-v1.2.3-eva2000.04.zip
unzip centmin-v1.2.3-eva2000.04.zip
cd centmin-v1.2.3mod
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' /usr/local/src/centmin-v1.2.3mod/centmin.sh
perl -pi -e 's/Brisbane/New_York/g' /usr/local/src/centmin-v1.2.3mod/centmin.sh
perl -pi -e 's/nginx centminmod/Envied Solutions Performance Network/g' /usr/local/src/centmin-v1.2.3mod/centmin.sh
chmod +x centmin.sh
# /etc/sysconfig/clock update from ZONE=Etc/UTC to whatever
# then do tzdata-update
# update mysql with mysql_tzinfo_to_sql
#./centmin.sh