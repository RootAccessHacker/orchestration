#!/bin/bash

echo "Enter the minions' account name"
read -r account_name

echo "Enter the minions' IP-address"
read -r ip

echo "Enter the minions' hostname"
read -r host_name

# RCE initiate saltstack install + point to master in config
ssh -t $account_name@$ip "sudo apt install curl; curl -L https://bootstrap.saltstack.com -o install_salt.sh ~/; sudo sh ~/install_salt.sh; sudo sed -i \"s/#master: salt/master: 192.168.90.131/\" /etc/salt/minion; sudo systemctl restart salt-minion"

sleep 10

# Adds minion to master by provided hostname
sudo salt-key --accept=$host_name -y

sleep 15

# Applies minion salt state
sudo salt "$host_name" state.apply minion-node

# Adds minion details to master munin host tree
sudo host_name=$host_name ip=$ip bash -c '
echo -e "
[NODES;$host_name]
    address $ip
    use_node_name yes" >> /etc/munin/munin.conf'

# Refreshes Munin monitor interface
sleep 8
sudo systemctl restart apache2

echo -e "\nConfiguration completed, have a nice day\n"


