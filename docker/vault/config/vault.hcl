disable_mlock = false  # 本番では true を false に変更

listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "127.0.0.1:8211"
  tls_cert_file    = "/vault/cert/vault-cert.pem"
  tls_key_file     = "/vault/cert/vault-key.pem"
  tls_disable      = 0
}

storage "consul" {
  address = "http://consul:8500"
  path    = "vault/"
}

api_addr = "https://profinaut.studiokeke.com"
ui       = true
