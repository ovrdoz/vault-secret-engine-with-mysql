# Vault secret engine with Mysql

This repository contains the materials for my sample of Secrets Engine with Vault.

The example is intended to demonstrate how a secret engine works dynamically with MySQL.
What will be presented is the step-by-step installation and configuration of vault and Mysql and finally the example of how to get a dynamic credential for the database connection.


## Getting Started

First, we need to configure run the provisioning of operation system, in this case, dependencies for ubuntu 18.04:

```
./00-provisioning.sh
```

This server is not designed to be a "best-practices" Vault server and is mostly designed for demonstrations such as this. It is not production-ready. Please do
not use this Vault setup in production.


First, we need to configure run the provisioning of operation system, in this case, dependencies for ubuntu 18.04:

```
./01-install-vault.sh
```

After running this script your vault is already installed and operating, go to http://<your-host>:8200 to access the web-ui.
The root token to login you get in this path of your vault instalation in **./access.txt

Run this step to join MySQL and vault and configure dependencies.

```
./02-configure.sh
```

## Running test

In the terminal run this command to generate a dynamic password

```
export VAULT_ADDR='http://0.0.0.0:8200' # this is a selector
export VAULT_TOKEN=<your-token>

vault read database/creds/my-role
```
or
```
curl \
    --header "X-Vault-Token: <your-token>" \
    --request GET \
    http://127.0.0.1:8200/v1/database/creds/mysql-role  | python -m json.tool
```

For effective testing, perform a test connection to MySQL with the dynamic user and pass

```
mysql -u <dynamic-user> -p 
```


