📘 Profinaut 本番運用マニュアル
🎯 概要
Profinautは以下を含む統合資産管理・取引自動化システムです。

Vaultによるシークレット管理・自動ローテーション

GitHub ActionsによるCI/CD・リリース

Dockerコンテナを使った本番サービス稼働

このマニュアルでは、運用に必要なコマンド・設定・運用フローを整理しています。

📂 構成概要
bash
コピーする
編集する
profinaut/
├── .env/                # 環境変数管理
│   ├── .env                # 共通設定
│   └── .env.vault          # Vault認証設定 (本番)
├── .github/workflows/  # CI/CD用Workflow
├── docker/             # Docker Compose / Vault構成
└── vault/              # Vault config/policy/cert
🔐 Vault運用
🎯 Vaultの目的
APIキー・DBパスワード等の安全な保存・取得

AppRoleによる権限分離

SecretIDの定期ローテーション

🚀 Vault起動コマンド
本番環境(Docker Compose)

powershell
cd docker
docker-compose up -d
コンテナ群:

profinaut_vault: Vault本体

profinaut_consul: Consul (ストレージ)

他サービス (Postgres, Kafka, MongoDB)

VaultはHTTPSでhttps://localhost:8200に起動します。

🔑 初期化 & アンシール
Vaultコンテナを初回起動したときのみ以下を行います:

docker exec -it profinaut_vault vault operator init
表示される Unseal Keys と Initial Root Token を安全に保管。

アンシール(起動時に1回)

docker exec -it profinaut_vault vault operator unseal
📝 AppRole設定
本番用 AppRoleは以下を使用:

Role	Role ID	Secret ID
profinaut-admin	199e233a-6da9-3ff0-f719-5e74c958ab75	49ebdbe0-5501-5ad7-487e-c82383439a37
profinaut-db	dfb0e033-3bfd-757f-7819-489ff6523e03	4cc16cf1-b094-6285-a721-9a24794f62f2
profinaut-kafka	a3e6cbb8-b11a-767a-65e6-184249cbaf06	0a46062b-ec73-a968-80ee-7e37de611077
profinaut-release	0a55db22-d48f-0a58-c167-440cb610663d	0fc601a6-b946-4dee-bc2b-c54277297efd
profinaut-readonly	8c6937e2-8f57-f4c8-fbc4-e9492bf5f7cb	bd31a8f5-1704-e47a-e1bc-a469d723d5ab

🛠️ シークレット管理コマンド

vault kv put secret/profinaut/db/credentials \
username="postgres" \
password="your_secure_password"

vault kv get secret/profinaut/db/credentials
⚙️ GitHub Actions CI/CD
🚀 主なWorkflow
Workflow名	内容	トリガー
Rust Test & Docker Build	Rustテスト、Dockerイメージビルド	push, 手動
Docker Build and Push	本番リリース用イメージビルド・DockerHub Push	タグPush(v*)
Docker Compose with Vault	Compose起動用	push, 手動
Release Build	バイナリビルド & GPG署名	タグPush
Vault Secrets Check	Vaultシークレット確認	手動, 定期（週1）
Rotate Vault SecretID	SecretIDローテーション	定期（週1）, 手動

🛡️ Secrets
GitHubに以下を登録済み:


PROFINAUT_VAULT_ADDR=https://127.0.0.1:8200
PROFINAUT_VAULT_ROLE_ID=<本番RoleID>
PROFINAUT_VAULT_SECRET_ID=<本番SecretID>
DOCKER_USERNAME=<DockerHubユーザ>
DOCKER_PASSWORD=<DockerHubパス>
♻️ SecretIDローテーション
SecretIDは定期的にローテーションします。

ローテーション用Workflow
Rotate Vault SecretID が週1で自動実行。
手動で実行も可能。

ローテーション手動手順 (PowerShell)

vault write -format=json auth/approle/role/profinaut-db/secret-id
出力結果の secret_id をGitHub Secretsに反映。

🛠️ 運用時によく使うコマンド
用途	コマンド例
Vault起動	docker-compose up -d
Vaultログ確認	docker logs -f profinaut_vault
Vaultアンシール	vault operator unseal
Vaultログイン	vault login
シークレット取得	vault kv get secret/profinaut/db/credentials
新しいSecretID発行	vault write -format=json auth/approle/role/profinaut-db/secret-id
GitHub Actions実行	GitHub Actions画面から手動実行

📝 注意事項
✅ .env.*ファイルはGit管理対象外にする
✅ SecretIDは1年以内に更新する
✅ Root Tokenは常時保管しない

ℹ️ 参考
Vault公式ドキュメント

GitHub Actions

Docker Compose

💡 よくあるユースケース & サンプル
📌 1. 新しい取引所APIキーを登録する
🔹 例：BinanceのAPIキー登録
Vaultのsecret/profinaut/binanceに保存

bash
コピーする
編集する
vault kv put secret/profinaut/binance \
api_key="binance_api_key_value" \
secret_key="binance_secret_key_value"
取得テスト


vault kv get secret/profinaut/binance
📌 2. 別の取引所を追加 (Bybit)
🔹 例：Bybit
bash
コピーする
編集する
vault kv put secret/profinaut/bybit \
api_key="bybit_api_key_value" \
secret_key="bybit_secret_key_value"
📌 3. 読み取り専用トークンでAPIキーを取得する
🔹 例：AppRoleトークンで取得
PowerShell:

powershell
コピーする
編集する
# ログイン
$login = vault write -format=json auth/approle/login `
    role_id="8c6937e2-8f57-f4c8-fbc4-e9492bf5f7cb" `
secret_id="bd31a8f5-1704-e47a-e1bc-a469d723d5ab"
$token = ($login | ConvertFrom-Json).auth.client_token

# 取得
vault kv get -format=json secret/profinaut/binance `
    -address=https://127.0.0.1:8200 `
-token=$token
📌 4. SecretIDローテーションを手動で行う
DB用のSecretIDをローテーション

bash
コピーする
編集する
vault write -format=json auth/approle/role/profinaut-db/secret-id
出力されるsecret_idをGitHub Secretsに差し替え。

📌 5. サービス起動時に環境変数に注入する
たとえばDocker Composeで起動前にVaultから環境変数をロードする:

Bash:

bash
コピーする
編集する
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_TOKEN=root

export POSTGRES_PASSWORD=$(vault kv get -field=password secret/profinaut/db/credentials)
export BINANCE_API_KEY=$(vault kv get -field=api_key secret/profinaut/binance)

docker compose up -d
📌 6. GitHub Actionsで取引所シークレットをビルド引数にする
yaml
コピーする
編集する
- name: 🔐 Load Binance Secrets
  env:
  VAULT_ADDR: ${{ secrets.PROFINAUT_VAULT_ADDR }}
  VAULT_TOKEN: ${{ secrets.PROFINAUT_VAULT_TOKEN }}
  run: |
  export BINANCE_API_KEY=$(vault kv get -field=api_key secret/profinaut/binance)
  export BINANCE_SECRET_KEY=$(vault kv get -field=secret_key secret/profinaut/binance)
  echo "BINANCE_API_KEY=$BINANCE_API_KEY" >> $GITHUB_ENV
  echo "BINANCE_SECRET_KEY=$BINANCE_SECRET_KEY" >> $GITHUB_ENV

- name: 🐳 Build Docker Image
  run: |
  docker build \
  --build-arg BINANCE_API_KEY=$BINANCE_API_KEY \
  --build-arg BINANCE_SECRET_KEY=$BINANCE_SECRET_KEY \
  -t myorg/profinaut:${GITHUB_REF##*/} .
  📌 7. 取引所APIキーを複数登録（冗長化）
  たとえばBinanceキーを複数バージョンで管理：

bash
コピーする
編集する
vault kv put secret/profinaut/binance/key1 api_key="key1" secret_key="secret1"
vault kv put secret/profinaut/binance/key2 api_key="key2" secret_key="secret2"
利用サービスで切替ロジック

メインキーが失敗したら次のキーを試行。

📌 8. GPG鍵など別種シークレットを管理
リリース署名用GPG鍵

bash
コピーする
編集する
vault kv put secret/profinaut/release SIGNING_KEY="$(cat ~/signingkey.asc)"
取得してImport:

bash
コピーする
編集する
vault kv get -field=SIGNING_KEY secret/profinaut/release > signingkey.asc
gpg --import signingkey.asc
📌 9. ステージング用環境変数管理
ステージング専用パスを分離:

bash
コピーする
編集する
vault kv put secret/profinaut/staging/db username="postgres" password="stagingpass"
vault kv put secret/profinaut/staging/binance api_key="stagingkey" secret_key="stagingsecret"
※本番とは別のAppRoleにアクセス権を付与

📌 10. すべてのシークレットを一覧取得
パス階層を確認:

bash
コピーする
編集する
vault kv list secret/profinaut
📋 備考
GitHub Actionsでは環境変数漏洩に注意
::add-mask::で必ずマスクする。

SecretIDは1年以内に更新推奨

権限はAppRole単位で分離

📝 まとめ
このようにVaultを中心に安全に多様なシークレットを管理できます。
今後、取引所やサービスが増えても

secret/profinaut/〇〇

profinaut-〇〇 のAppRole
という方針で拡張可能です。