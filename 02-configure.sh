#!/usr/bin/env bash
set -Eeuo pipefail

## configure Mysql
echo "--> Configue mysql with steps"
sudo mysql_secure_installation utility
sudo bash -c 'echo "skip-grant-tables" >> /etc/mysql/mysql.conf.d/mysqld.cnf'

echo "--> Restarting mysql server"
sudo systemctl restart mysql

echo "--> Updating user root and flush privileges"
mysql -p'admin' -u root -Bse "use mysql; 
update user set authentication_string=PASSWORD(\"mysql\") where User='root'; 
update user set plugin=\"mysql_native_password\" where User='root'; 
flush privileges;"

# configure vault
echo "--> Exporting variables from env vault"
export VAULT_ADDR='http://0.0.0.0:8200'
echo -n "Input your VAULT_TOKEN: "
read answer
export VAULT_TOKEN=${answer}

# configure vault to access mysql 
echo "--> Enable mysql secret engine to vault"
vault secrets enable database

echo "--> Configure Vault to know how to connect to the MySQL"
vault write database/config/my-mysql-database \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(127.0.0.1:3306)/" \
    allowed_roles="mysql-role" \
    username="root" \
    password="mysql"

echo "--> For example, lets create a \"readonly\" role"
vault write database/roles/mysql-role \
    db_name=my-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1m" \
    max_ttl="10m"

echo "--> Enable the userpass for static access"
vault auth enable userpass

echo "--> Create policies"
vault policy write mysql-policy ./files/mysql.hcl

echo "--> Create user and associate a policy"
vault write auth/userpass/users/diego_m password="diego_m" policies="mysql-policy"
vault write auth/userpass/users/maria_m password="maria_m" policies="default"

echo "--> Cat the accessor"
vault auth list -format=json | jq -r '.["userpass/"].accessor' > accessor.txt

echo "--> Create entry name and alias"
# first user
vault write -format=json identity/entity name="Diego Maia" \
     policies="mysql-policy" \
     metadata=organization="Hashicorp" \
     metadata=team="Administrator" \
     | jq -r ".data.id" > entity_id.txt

vault write identity/entity-alias name="diego_m" \
     canonical_id=$(cat entity_id.txt) \
     mount_accessor=$(cat accessor.txt)

# second user
vault write -format=json identity/entity name="Maria Maia" \
     policies="default" \
     metadata=organization="Hashicorp" \
     metadata=team="Default" \
     | jq -r ".data.id" > entity_id.txt


vault write identity/entity-alias name="maria_m" \
     canonical_id=$(cat entity_id.txt) \
     mount_accessor=$(cat accessor.txt)

echo "--> Test process of createndital build"
echo "--> vault read database/creds/mysql-role"
vault read database/creds/my-role