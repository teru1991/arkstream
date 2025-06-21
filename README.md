📘 ArkStream - 開発環境セットアップ手順
ArkStreamは、高速なデータ収集・処理・取引実行を実現する統合型トレーディングシステムです。本プロジェクトの開発を開始するための環境構築手順を以下にまとめます。

📁 ディレクトリ構成（抜粋）
arkstream/
├── config/                  # Python依存パッケージ管理
│   └── requirements.txt
├── docker/                  # Docker構成ファイルとスクリプト
│   ├── docker-compose.yml
│   ├── docker-compose.monitoring.yml
│   └── scripts/
│       └── init_kafka_topics.sh
├── env/                     # 分割された.envファイル群（秘匿）
│   ├── .env
│   ├── .env.api_binance
│   └── .gitkeep
├── scripts/                 # セットアップ・補助スクリプト
│   ├── setup.sh
│   └── init_env_files.sh
├── src/                     # Rust / Python ソースコード
├── .gitignore
└── README.md
✅ 前提条件（事前インストール）
ツール名	バージョン例	備考
Python	3.9〜3.11	python3 --version
Rust (cargo)	1.70+	rustup, cargo
Docker Desktop	最新安定版	docker, docker-compose 含む
Git	2.30+	GitHub連携のため
IntelliJ IDEA	Ultimate 版推奨	Rust & Python プラグイン必要

🚀 セットアップ手順
① リポジトリをクローン
bash
コピーする
編集する
git clone git@github.com:teru1991/arkstream.git
cd arkstream
② .env ファイルを生成（未作成時）
bash
コピーする
編集する
bash scripts/init_env_files.sh
env/ フォルダ以下に、各取引所・DB・Kafka・Discord用の .env ファイルが生成されます。

③ 開発環境構築の一括スクリプト
bash
コピーする
編集する
bash scripts/setup.sh
このスクリプトにより以下が実行されます：

Python仮想環境の作成と依存ライブラリのインストール

Dockerコンテナ（DB/Kafka/Grafana等）の起動

Kafkaトピックの初期化

Rustコードのビルド

📊 モニタリング確認
Grafana にアクセスすることでシステム状態を可視化できます：

makefile
コピーする
編集する
http://localhost:3000
ユーザー名: admin
パスワード: admin
🛠️ よくある問題
問題	解決策
Kafkaトピック作成失敗（No such container）	Dockerコンテナ起動後、再度 setup.sh を実行してください
requirements.txt が無い	config/requirements.txt が存在するか確認
Prometheus起動失敗（mount error）	docker/prometheus.yml ファイルが実在するか確認し、volume の設定を修正

🔐 セキュリティ注意点
.env ファイル群には秘密鍵/APIキーが含まれるため、絶対にGitにコミットしないでください。

.gitignore によって env/ フォルダは除外されています。

📦 今後のTODO（例）
CI/CD の GitHub Actions 導入

各モジュールごとのユニットテスト

.env 管理の自動チェックツール導入

PrometheusのPushGateway導入

👤 開発者情報
開発者: teru1991

ライセンス: MIT