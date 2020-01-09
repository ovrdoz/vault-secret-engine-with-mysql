path "database/*" {
  capabilities = ["create"]
}
path "database/creds/mysql-role" {
  capabilities = ["read"]
}