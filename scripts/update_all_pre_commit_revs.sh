#!/bin/bash
set -e

YAML_FILE=".pre-commit-config.yaml"
TMP_FILE=".pre-commit-config.yaml.tmp"

echo "🔍 .pre-commit-config.yaml 内の repo を確認中..."

# grepで repo: 行を抽出 → URLだけをリスト化
REPOS=$(grep '^\s*- repo:' "$YAML_FILE" | awk '{print $3}' | sort -u)

cp "$YAML_FILE" "$TMP_FILE"

for REPO in $REPOS; do
    echo "🔎 $REPO の最新タグを取得中..."

    # タグの中から v{semver} 形式のみ抽出し、ソートして最新を選択
    LATEST_TAG=$(git ls-remote --tags "$REPO" 2>/dev/null | \
        awk '{print $2}' | \
        grep -E 'refs/tags/v[0-9]+\.[0-9]+' | \
        sed 's#refs/tags/##' | \
        sort -Vr | \
        head -n 1)

    if [ -z "$LATEST_TAG" ]; then
        echo "⚠️  タグが見つからなかったためスキップ: $REPO"
        continue
    fi

    echo "✅ 最新タグ: $LATEST_TAG"

    # 対応する repo の次の行の rev を最新に置換
    sed -i.bak -E "/repo: $REPO/{n;s/rev: .*/rev: $LATEST_TAG/}" "$TMP_FILE"
done

# 最終的に反映
mv "$TMP_FILE" "$YAML_FILE"

echo "🎉 .pre-commit-config.yaml の rev を全て更新しました！"
