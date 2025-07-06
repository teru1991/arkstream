# KV v2 metadata
path "secret/metadata/arkstream/db/*" {
  capabilities = ["list"]
}

# KV v2 data
path "secret/data/arkstream/db/*" {
  capabilities = ["read"]
}
