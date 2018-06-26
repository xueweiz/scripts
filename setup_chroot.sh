sudo su

apt-get install -y git vim ssh
service ssh start
git config --global user.email "kentxuewei@gmail.com"
git config --global user.name "Xuewei Zhang"

apt-get install -y iptables
echo "/sbin/iptables -I INPUT -p tcp --dport 22 -j ACCEPT" > /etc/rc.local
echo "/sbin/iptables -I INPUT -p tcp --dport 139 -j ACCEPT" >> /etc/rc.local
echo "/sbin/iptables -I INPUT -p tcp --dport 445 -j ACCEPT" >> /etc/rc.local
echo "/sbin/iptables -I INPUT -p udp --dport 137 -j ACCEPT" >> /etc/rc.local
echo "/sbin/iptables -I INPUT -p udp --dport 138 -j ACCEPT" >> /etc/rc.local

source /etc/rc.local

apt-get install -y samba
ln -s /media/removable/4T /home/4T
ln -s /media/removable/2T /home/2T

smbpasswd -a xuewei

cp /etc/samba/smb.conf /tmp/
echo "[4T]" > /etc/samba/smb.conf
echo "path = /home/4T" >> /etc/samba/smb.conf
echo "valid users = xuewei"  >> /etc/samba/smb.conf
echo "read only = no" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "[2T]" > /etc/samba/smb.conf
echo "path = /home/2T" >> /etc/samba/smb.conf
echo "valid users = xuewei"  >> /etc/samba/smb.conf
echo "read only = no" >> /etc/samba/smb.conf

service smbd restart









