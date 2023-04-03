#!/usr/bin/env bash
set -x
exec >/var/log/stackscript.log 2>&1
# <UDF name="ubuntu_password" label="'ubuntu' User Password (required)" example="Abc1234!" default="P1D1wUf2xPMuikqe#K0#8">
# <UDF name="node_version" label="Node.js version (required)" example="18.13.0" default="18.13.0">
# <UDF name="hdb_version" label="HarperDB Version (required, pulls from NPM)" example="4.0.5" default="4.0.5">
# <UDF name="hdb_admin_username" label="HDB_ADMIN_USERNAME (required)" example="HDB_ADMIN" default="HDB_ADMIN">
# <UDF name="hdb_admin_password" label="HDB_ADMIN_PASSWORD (required)" example="Abc1234!" default="A^ikY72j&!#vZgp43wHXx">
# <UDF name="operationsapi_network_https" label="OPERATIONSAPI_NETWORK_HTTPS (required) (true/false)" example="true" default="true">
# <UDF name="customfunctions_network_https" label="CUSTOMFUNCTIONS_NETWORK_HTTPS (required) (true/false)" example="true" default="true">
# <UDF name="operationsapi_network_port" label="OPERATIONSAPI_NETWORK_PORT (required)" example="9925" default="9925">
# <UDF name="clustering_enabled" label="CLUSTERING_ENABLED (required) (true/false)" example="true" default="true">
# <UDF name="clustering_user" label="CLUSTERING_USER (required)" example="cluster_user" default="cluster_user">
# <UDF name="clustering_password" label="CLUSTERING_PASSWORD (required)" example="Abc1234!" default="mji&YmgC0XH8YNT*w31Xi">
# <UDF name="clustering_nodename" label="CLUSTERING_NODENAME (required)" example="hdb01" default="hdb01">
# Update installed packages
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade --with-new-pkgs
apt-get update && apt-get -y upgrade
# Set net.ipv4 settings
echo -e "net.ipv4.tcp_tw_reuse='1'\nnet.ipv4.ip_local_port_range='1024 65000'\nnet.ipv4.tcp_fin_timeout='15'" >> /etc/sysctl.conf
# Create ubuntu user
useradd --create-home --shell /bin/bash --groups sudo ubuntu 
echo -e "$UBUNTU_PASSWORD\n$UBUNTU_PASSWORD" | passwd ubuntu
# Adjust the per-user open file limits
echo "ubuntu soft nofile 1000000" | tee -a /etc/security/limits.conf
echo "ubuntu hard nofile 1000000" | tee -a /etc/security/limits.conf
mkdir /home/ubuntu/hdb
chown -R ubuntu:ubuntu /home/ubuntu/hdb
chmod 775 /home/ubuntu/hdb
# Create script to be run as ubuntu user
cat > /tmp/subscript.sh << EOF
#!/bin/bash
set -x
# Install Node Version Manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
. /home/ubuntu/.nvm/nvm.sh
. /home/ubuntu/.bashrc
# Install Node.js using Node Version Manager
nvm install $NODE_VERSION
npm config set nodedir /home/ubuntu/.nvm/versions/node/v"$NODE_VERSION"/
# Install HarperDB
npm install -g harperdb@"$HDB_VERSION"
harperdb --TC_AGREEMENT yes --ROOTPATH /home/ubuntu/hdb --OPERATIONSAPI_NETWORK_PORT $OPERATIONSAPI_NETWORK_PORT --HDB_ADMIN_USERNAME '$HDB_ADMIN_USERNAME' --HDB_ADMIN_PASSWORD '$HDB_ADMIN_PASSWORD' --CLUSTERING_USER '$CLUSTERING_USER' --CLUSTERING_PASSWORD '$CLUSTERING_PASSWORD' --CLUSTERING_NODENAME '$CLUSTERING_NODENAME' --CLUSTERING_ENABLED $CLUSTERING_ENABLED --OPERATIONSAPI_NETWORK_HTTPS $OPERATIONSAPI_NETWORK_HTTPS --CUSTOMFUNCTIONS_NETWORK_HTTPS $CUSTOMFUNCTIONS_NETWORK_HTTPS
# Add cron job to start HarperDB on startup
crontab -l 2>/dev/null; echo "@reboot PATH=\"/home/ubuntu/.nvm/versions/node/v"$NODE_VERSION"/bin:$PATH\" && harperdb" | crontab -
EOF
# Execute script as ubuntu user
chown ubuntu:ubuntu /tmp/subscript.sh
chmod +x /tmp/subscript.sh
sleep 1
su - ubuntu -c "/tmp/subscript.sh"
