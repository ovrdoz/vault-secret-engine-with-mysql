#!/usr/bin/env bash
set -Eeuo pipefail

echo "--> Configue mysql with steps"
sudo mysql_secure_installation utility
sudo bash -c 'echo "skip-grant-tables" >> /etc/mysql/mysql.conf.d/mysqld.cnf'

echo "--> Restarting mysql server"
sudo systemctl restart mysql

echo "--> Updating user root and flush privileges"
mysql -p'admin' -u root -Bse "use mysql; 
update user set authentication_string=PASSWORD(\"admin\") where User='root'; 
update user set plugin=\"mysql_native_password\" where User='root'; 
flush privileges;"

echo "--> Exporting variables from env vault"
export VAULT_ADDR='http://0.0.0.0:8200'
echo -n "Input your VAULT_TOKEN: "
read answer
export VAULT_TOKEN=${answer}


echo "--> Enable mysql secret engine to vault"
vault secrets enable database

echo "--> Configure Vault to know how to connect to the MySQL"
vault write database/config/my-mysql-database \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(127.0.0.1:3306)/" \
    allowed_roles="my-role" \
    username="root" \
    password="admin"

echo "--> For example, lets create a \"readonly\" role"
vault write database/roles/my-role \
    db_name=my-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1m" \
    max_ttl="10m"

echo "--> To generate a new set of credentials, we simply read from that role"
echo "--> vault read database/creds/my-role"
vault read database/creds/my-role