#!/usr/bin/env bash
set -Eeuo pipefail

export VAULT_VERSION=1.3.1

echo "--> Downloading"
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip &> /dev/null

echo "--> Unpacking and installing"
unzip vault_${VAULT_VERSION}_linux_amd64.zip  &> /dev/null
sudo mv vault /usr/bin/vault
sudo chmod +x /usr/bin/vault

echo "--> Create Vault data directories"
sudo mkdir /etc/vault
sudo mkdir -p /var/lib/vault/data

echo "--> Then create user named vault."
sudo useradd --system --home /etc/vault --shell /bin/false vault
sudo chown -R vault:vault /etc/vault /var/lib/vault/

echo "--> Create a Vault service file"
sudo cp ./files/vault.service /etc/systemd/system/vault.service
sudo chmod +x /etc/systemd/system/vault.service

echo "--> Add basic configuration settings for Vault to /etc/vault/config.hcl file"
sudo cp ./files/config.hcl /etc/vault/config.hcl

echo "--> Installing completions"
vault -autocomplete-install
complete -C /usr/bin/vault vault
sudo systemctl enable vault 
sudo systemctl start vault

echo "--> Done!"