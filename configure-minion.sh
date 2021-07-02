#!/bin/bash

echo -e "\nWhat will the node be doing?\n[1] Run a Wordpress instance\n[2] Run a Docker instance\n[Default] The target will only get default configuration.\n"
read -r choice

echo "Enter the minions' hostname"
read -r host_name

echo "Enter the minions' IP-address"
read -r ip

echo "Enter the minions' account name"
read -r account_name

# RCE initiate saltstack install + point to master in config
echo "Sending payload to minion"
ssh -t $account_name@$ip "sudo apt install curl; curl -L https://bootstrap.saltstack.com -o install_salt.sh ~/; sudo sh ~/install_salt.sh && sudo sed -i \"s/#master: salt/master: 192.168.90.131/\" /etc/salt/minion && sudo systemctl restart salt-minion"

sleep 20

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

echo -e "\nBasic configuration completed\n"

sleep 5


# More specific configuration
if [ $choice == "1" ]; then

    sudo salt "$host_name" state.apply configure-wordpress
    
    echo "Enter a database name:"
    read -r dbname

    echo "Enter a database username:"
    read -r dbuser

    echo "Enter a database user password:"
    read -r dbpass

    echo "Enter root password to make installation easier:"
    read -sp pass


    sudo ssh -t $account_name@$ip "sudo mv /var/www/html/wp-config-sample.php /etc/wordpress/config-${ip}.php"
    
    sudo ssh -t $account_name@$ip "sudo sed -i -e 's/database_name_here/${dbname}/' /etc/wordpress/config-${ip}.php"
    sudo ssh -t $account_name@$ip "sudo sed -i -e 's/username_here/${dbuser}/' /etc/wordpress/config-${ip}.php"
    sudo ssh -t $account_name@$ip "sudo sed -i -e 's/password_here/${dbpass}/' /etc/wordpress/config-${ip}.php"


    echo -e "\nConfiguration complete, resuming to database creation...\n"
    sleep 3


    sudo ssh -t $account_name@$ip "sudo mariadb -u root -p ${pass} -e 'CREATE DATABASE ${dbname};'"
    sudo ssh -t $account_name@$ip "sudo mariadb -u root -p ${pass} -e 'CREATE USER "${dbuser}"@"%" IDENTIFIED BY "${dbpass}";'"
    sudo ssh -t $account_name@$ip "sudo mariadb -u root -p ${pass} -e 'GRANT ALL PRIVILEGES ON ${dbname}.* TO "${dbuser}"@"%";'"



elif [ $choice == "2" ]; then
    sudo salt "$host_name" state.apply configure-docker
else 
    echo "Exiting."
    exit
fi
