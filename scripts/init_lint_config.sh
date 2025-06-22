#!/bin/bash
set -e

echo "🧼 Linter/Formatter 初期設定を作成中..."

# Rust
cat <<EOF > .rustfmt.toml
edition = "2021"
max_width = 100
use_small_heuristics = "Max"
EOF
echo "✅ .rustfmt.toml を作成しました"

# Python
cat <<EOF > pyproject.toml
[tool.black]
line-length = 100
target-version = ['py39']
include = '\.pyi?$'

[tool.ruff]
line-length = 100
target-version = "py39"
extend-select = ["I", "UP", "E", "F", "B", "C4"]
ignore = ["E501"]
EOF
echo "✅ pyproject.toml を作成しました"

# TypeScript / React (ESLint)
mkdir -p frontend
cat <<EOF > frontend/.eslintrc.json
{
  "env": {
    "browser": true,
    "es2021": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 12,
    "sourceType": "module",
    "ecmaFeatures": {
      "jsx": true
    }
  },
  "plugins": [
    "react",
    "@typescript-eslint"
  ],
  "rules": {
    "semi": ["error", "always"],
    "quotes": ["error", "double"]
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
EOF
echo "✅ frontend/.eslintrc.json を作成しました"
