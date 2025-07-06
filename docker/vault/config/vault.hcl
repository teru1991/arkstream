disable_mlock = true

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/vault/cert/vault-cert.pem"
  tls_key_file  = "/vault/cert/vault-key-rsa.pem"
}

storage "consul" {
  address = "consul:8500"
  path    = "vault/"
}

api_addr = "https://localhost:8200"

ui = true
