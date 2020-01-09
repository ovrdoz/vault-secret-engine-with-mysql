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
var1="$(cat <<EOF | sudo tee /etc/systemd/system/vault.service
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault/config.hcl

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault/config.hcl
ExecReload=/bin/kill --signal HUP
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
)"

echo "--> Add basic configuration settings for Vault to /etc/vault/config.hcl file"
var2="$(cat <<EOF | sudo tee /etc/vault/config.hcl
disable_cache = true
disable_mlock = true
ui = true
listener "tcp" {
   address          = "0.0.0.0:8200"
   tls_disable      = 1
}
storage "file" {
   path  = "/var/lib/vault/data"
}
api_addr                = "http://0.0.0.0:8200"
max_lease_ttl           = "10h"
default_lease_ttl       = "10h"
cluster_name            = "vault"
raw_storage_endpoint    = true
disable_sealwrap        = true
disable_printable_check = true
EOF
)"

echo "--> Installing completions"
vault -autocomplete-install
complete -C /usr/bin/vault vault
sudo systemctl enable vault 
sudo systemctl start vault
sudo systemctl status vault

echo "--> Done!"
echo "--> Important! In this example, you need to go to http://<your-host>:8200 and generate key-root, key-shares key-threshold, because this will be needed in the next steps."