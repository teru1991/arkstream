# KV v2 metadata
path "secret/metadata/profinaut/db/*" {
  capabilities = ["list"]
}

# KV v2 data
path "secret/data/profinaut/db/*" {
  capabilities = ["read"]
}
