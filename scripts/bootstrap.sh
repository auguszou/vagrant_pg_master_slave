apt-get update
apt-get install -yy curl vim wget net-tools sshpass acl

echo "ubuntu:vagrant" | sudo chpasswd
echo "root:vagrant" | chpasswd

sed -i 's/^PermitRootLogin.*$/PermitRootLogin yes/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart