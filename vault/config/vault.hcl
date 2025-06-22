disable_mlock = true

listener "tcp" {
  address     = "0.0.0.0:18201"
  tls_disable = true
}

storage "file" {
  path = "/vault/data"
}

api_addr = "http://localhost:18201"
