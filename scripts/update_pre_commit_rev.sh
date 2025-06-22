#!/bin/bash
set -e

CONFIG_FILE=".pre-commit-config.yaml"
TMP_FILE=".pre-commit-config.tmp.yaml"

echo "🔄 pre-commit の rev を最新タグに更新します..."

# ファイルを行ごとに処理
while IFS= read -r line; do
  if [[ $line =~ ^[[:space:]]*- repo:\ (https://[a-zA-Z0-9./_-]+)$ ]]; then
    repo="${BASH_REMATCH[1]}"
    echo "📦 リポジトリ検出: $repo"

    # 最新の tag を取得
    latest_tag=$(git ls-remote --tags "$repo" | awk -F/ '/refs\/tags\/v?[0-9]+\.[0-9]+(\.[0-9]+)?$/ {print $NF}' | sort -V | tail -n1)

    if [[ -z $latest_tag ]]; then
      echo "⚠️  タグが見つかりません: $repo"
      echo "$line" >> "$TMP_FILE"
      continue
    fi

    echo "  → 最新タグ: $latest_tag"
    echo "$line" >> "$TMP_FILE"

    # 次の行 (rev) を置き換える
    read -r next_line
    if [[ $next_line =~ ^[[:space:]]*rev:\ .* ]]; then
      indent=$(echo "$next_line" | sed -E 's/( *)rev:.*/\1/')
      echo "${indent}rev: $latest_tag" >> "$TMP_FILE"
    else
      echo "$next_line" >> "$TMP_FILE"
    fi
  else
    echo "$line" >> "$TMP_FILE"
  fi
done < "$CONFIG_FILE"

# 元ファイルと差し替え
mv "$TMP_FILE" "$CONFIG_FILE"
echo "✅ 最新タグへの更新が完了しました: $CONFIG_FILE"
