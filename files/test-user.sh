#!/bin/bash
echo "Get vault token"
token=$(curl -X POST -s http://127.0.0.1:8200/v1/auth/userpass/login/$1 -d "{\"password\": \"$1\"}" | ../lib/jq -r '.auth.client_token')
echo "The user token $token"
curl -X GET  -s http://127.0.0.1:8200/v1/database/creds/mysql-role -H "X-Vault-Token: $token" | python -m json.tool
