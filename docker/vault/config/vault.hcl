# 🔐 Mlock制御（Windowsでは無効にする）
disable_mlock = true

# 📡 通信設定（Cloudflare Origin CAまたはLet's Encrypt対応）
listener "tcp" {
  address         = "0.0.0.0:8200"  # 正しいアドレスとポート
  tls_disable     = false
  tls_cert_file   = "/vault/cert/vault-cert.pem"  # 証明書のパス
  tls_key_file    = "/vault/cert/vault-key.pem"   # 秘密鍵のパス
  tls_min_version = "tls12"
}


# 💾 ストレージ設定（fileベースの永続化）
storage "file" {
  path = "/vault/data"
}

# 🌐 UIとログ設定
ui = true
log_level = "info"

# 🔗 Cloudflare経由で公開されるFQDNを指定（重要）
api_addr     = "https://vault.profinaut.studiokeke.com:8200"
cluster_addr = "https://vault.profinaut.studiokeke.com:8200"

# 🛡️ Let's Encrypt + Cloudflare DNS 自動証明書取得設定（Vault側のACME構成）
# acme {
#   enabled        = true
#   challenge_type = "dns"
#   dns_provider   = "cloudflare"
#   email          = "your@email.com"
# }
