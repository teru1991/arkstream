# 🔐 Mlock制御
disable_mlock = false  # 本番では false（セキュアメモリ保護有効）

# 📡 通信設定（HTTPS）
listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "127.0.0.1:8211"
  tls_cert_file    = "/vault/cert/vault-cert.pem"
  tls_key_file     = "/vault/cert/vault-key.pem"
  tls_disable      = 0
  tls_min_version  = "tls12"
}

# 💾 ストレージ設定（Consul）
storage "consul" {
  address = "http://consul:8500"
  path    = "vault/"
}

# 🌐 APIとUIの有効化
api_addr = "https://profinaut.studiokeke.com"
cluster_addr = "https://127.0.0.1:8211"
ui = true

# 🪵 Auditログ（ログ永続化用）
audit {
  file_path = "/vault/log/audit.log"
  log_raw   = true
}
