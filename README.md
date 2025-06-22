# 📘 ArkStream - 開発環境セットアップ手順

**ArkStream** は、高速なデータ収集・処理・取引実行を実現する統合型トレーディングシステムです。  
本プロジェクトの開発を開始するための環境構築手順を以下にまとめます。

---

## 📁 ディレクトリ構成（抜粋）

```
arkstream/
├── config/                  # Python依存パッケージ管理
│   └── requirements.txt
├── docker/                  # Docker構成ファイルとスクリプト
│   ├── docker-compose.yml
│   ├── docker-compose.monitoring.yml
│   └── scripts/
│       └── init_kafka_topics.sh
├── env/                     # 分割された .env ファイル群（秘匿）
│   ├── .env
│   ├── .env.api_binance
│   └── .gitkeep
├── scripts/                 # セットアップ・補助スクリプト
│   ├── setup.sh
│   └── init_env_files.sh
├── src/                     # Rust / Python ソースコード
├── .gitignore
└── README.md
```

---

## ✅ 前提条件（事前インストール）

| ツール名         | バージョン例     | 備考                           |
|------------------|------------------|--------------------------------|
| Python           | 3.9〜3.11         | `python3 --version` で確認     |
| Rust (cargo)     | 1.70+             | `rustup`, `cargo` を使用       |
| Docker Desktop   | 最新安定版       | `docker`, `docker-compose` 含む |
| Git              | 2.30+            | GitHub連携のため               |
| IntelliJ IDEA    | Ultimate 推奨    | Rust & Python プラグイン必要   |

---

## 🚀 セットアップ手順

### ① リポジトリをクローン

```bash
git clone git@github.com:teru1991/arkstream.git
cd arkstream
```

---

### ② `.env` ファイルを生成（未作成時）

```bash
bash scripts/init_env_files.sh
```

- `.env/.example` 内のテンプレートから `.env/` に展開されます。
- 各取引所・DB・Kafka・Discord用の `.env` ファイルが生成されます。

---

### ③ 開発環境構築の一括スクリプト

```bash
bash scripts/setup.sh
```

このスクリプトにより以下が実行されます：

- Python仮想環境の作成と依存ライブラリのインストール
- Dockerコンテナ（DB / Kafka / Grafana など）の起動
- Kafkaトピックの初期化
- Rustコードのビルド

---

## 📊 モニタリング確認

Grafana にアクセスしてシステム状態を確認可能です：

🔗 [http://localhost:3000](http://localhost:3000)  
ログイン情報：
- ユーザー名: `admin`
- パスワード: `admin`

---

## 🛠️ よくある問題と対処法

| 問題内容 | 解決策 |
|----------|--------|
| Kafkaトピック作成失敗（No such container） | Dockerコンテナを起動した後、再度 `setup.sh` を実行してください |
| `requirements.txt` が見つからない | `config/requirements.txt` の存在を確認 |
| Prometheus起動失敗（mount error） | `docker/prometheus.yml` が存在するか確認し、volume 設定を調整 |

---

## 🔐 セキュリティ注意点

- `.env` ファイル群には **APIキーや秘密鍵** を含みます。
- **絶対にGitにコミットしないでください。**
- `.gitignore` により `env/` フォルダ全体が除外されています。

---

## 📦 今後の TODO

- ✅ CI/CD の GitHub Actions 導入
- ✅ 各モジュールごとのユニットテスト
- ✅ `.env` 管理の自動チェックツール導入
- ✅ Prometheus PushGateway の導入

---

## 👤 開発者情報

- **開発者**: [@teru1991](https://github.com/teru1991)
- **ライセンス**: MIT

---
