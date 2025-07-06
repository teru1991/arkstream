path "secret/metadata/arkstream/kafka/*" {
  capabilities = ["list"]
}

path "secret/data/arkstream/kafka/*" {
  capabilities = ["read"]
}
