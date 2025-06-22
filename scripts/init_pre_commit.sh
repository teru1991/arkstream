#!/bin/bash
set -e

echo "🧪 pre-commit 環境を初期化中..."

# Python環境に pre-commit をインストール（venv or グローバル）
pip install --upgrade pip
pip install pre-commit ruff black

# Rust環境に clippy を追加
rustup component add clippy

# Node.js バージョン確認（v18以上推奨）
NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  echo "⚠️ Node.js v18 以上が必要です。現在: $(node -v)"
else
  echo "✅ Node.js バージョン: $(node -v)"
fi

# Node環境に eslint をインストール
npm install --save-dev eslint

# pre-commit フックを有効化
pre-commit install

# pre-commit 設定ファイルの初期化チェック
if [ ! -f .pre-commit-config.yaml ]; then
  echo "⚠️ .pre-commit-config.yaml が見つかりません"
  exit 1
fi

# 初回実行
pre-commit run --all-files

echo "🎉 pre-commit 初期化完了"
