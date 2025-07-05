# vault.hcl (本番用設定)

disable_mlock = true  # メモリロックを無効化

# TLS設定（証明書ファイルのパスはローカルに保存されているものを使用）
listener "tcp" {
  address     = "0.0.0.0:8200"  # ポート8200で待機
  tls_cert_file = "/vault/cert/vault-cert.pem"  # 証明書のパス
  tls_key_file  = "/vault/cert/vault-key.pem"   # 鍵ファイルのパス
}

# ストレージバックエンド（本番環境にはConsulを使用）
storage "consul" {
  address = "localhost:8500"
  path    = "vault/"
}

# Vault APIのアドレス（環境変数を使って設定）
api_addr = "${VAULT_ADDR}"

# シール設定（AWS KMSを使ったセキュリティ強化）
seal "awskms" {
  region = "us-east-1"
  kms_key_id = "arn:aws:kms:us-east-1:111122223333:key/abcd-1234"  # AWS KMSのキーID
}

# Vault UIを有効化（UIでの操作が可能）
ui = true
