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

After running this script your vault is already installed and operating, but you need to do root-token generation, so you should go to http://<your-host>:8200, follow the steps, generate keys with values for shares (5) and threshold (3). So you will get a result as below and finally copy the root_token that will be requested in the next step.

```
  "keys": [
    "d9213cb21c25bd3d955a95294dd92dbb687adb445a7769fc02bf27dba7215b2e3d",
    "224077949a16f43035bcda63f54a0546e598a8a0f9404f33ecd639effc457dc014",
    "74d485e6ab6365847e54c1f576c0c0e7c9e57a4cb5235859f7f918962359901b5b",
    "eb91c9b4d936e05bcf0c37cf3479370a70fcdd9bbbf1a3e7f5931b6cd5ef692e24",
    "6507759a1930159f623b9c6df4b326a1408cfa0d419133b568c26c19d2f70fc1f7"
  ],
  "keys_base64": [
    "2SE8shwlvT2VWpUpTdktu2h620Rad2n8Ar8n26chWy49",
    "IkB3lJoW9DA1vNpj9UoFRuWYqKD5QE8z7NY57/xFfcAU",
    "dNSF5qtjZYR+VMH1dsDA58nleky1I1hZ9/kYliNZkBtb",
    "65HJtNk24FvPDDfPNHk3CnD83Zu78aPn9ZMbbNXvaS4k",
    "ZQd1mhkwFZ9iO5xt9LMmoUCM+g1BkTO1aMJsGdL3D8H3"
  ],
  "root_token": "s.jE5QymtXiV9yiRdyc3qMzwDg"
}
```

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
    http://127.0.0.1:8200/v1/database/creds/my-role  | python -m json.tool
```

For effective testing, perform a test connection to MySQL with the dynamic user and pass

```
mysql -u <dynamic-user> -p 
```


