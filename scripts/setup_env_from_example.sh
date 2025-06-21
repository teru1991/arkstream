#!/bin/bash
set -e

# 📁 ディレクトリ設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_DIR="$PROJECT_ROOT/.env"
EXAMPLE_DIR="$ENV_DIR/.example"

echo "📂 example dir : $EXAMPLE_DIR"
echo "📂 target  dir : $ENV_DIR"
echo ""

if [ ! -d "$EXAMPLE_DIR" ]; then
  echo "❌ .env/.example ディレクトリが存在しません: $EXAMPLE_DIR"
  exit 1
fi

# 📝 .example ファイル一覧取得
example_files=("$EXAMPLE_DIR"/*.example)
if [ ${#example_files[@]} -eq 0 ]; then
  echo "⚠️ .env/.example 内に .example ファイルが見つかりません"
  exit 0
fi

echo "🔍 未展開の .env.example ファイル一覧:"
missing_count=0
for example_file in "${example_files[@]}"; do
  [ -e "$example_file" ] || continue
  base_name="$(basename "$example_file" .example)"
  target_file="$ENV_DIR/$base_name"

  if [ ! -f "$target_file" ]; then
    echo "🆕 $base_name"
    ((missing_count++))
  fi
done

if [ "$missing_count" -eq 0 ]; then
  echo "✅ すべての .env ファイルは作成済みです"
  exit 0
fi

echo ""
read -p "🚀 上記の .env ファイルを作成しますか？ (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "⏹️ 中断しました"
  exit 0
fi

echo ""
# 🌀 各 example ファイル処理
for example_file in "${example_files[@]}"; do
  [ -e "$example_file" ] || continue
  base_name="$(basename "$example_file" .example)"
  target_file="$ENV_DIR/$base_name"

  if [ -f "$target_file" ]; then
    echo "⚠️ $base_name はすでに存在します"
    read -p "➡️ 上書きしますか？ (y/n): " overwrite
    if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
      echo "⏭️ スキップしました: $base_name"
      continue
    fi

    # 🔐 バックアップ
    cp "$target_file" "$target_file.bak"
    echo "🗂️ バックアップ作成済み: $target_file.bak"
  fi

  # 💬 コメント付きでコピー（各行の先頭にヒント）
  echo "📄 展開中: $base_name"
  {
    echo "# ====== ${base_name} ======"
    while IFS= read -r line || [ -n "$line" ]; do
      if [[ "$line" == *=* ]]; then
        key="${line%%=*}"
        echo "# Hint: $key"
        echo "$line"
      else
        echo "$line"
      fi
    done < "$example_file"
  } > "$target_file"

  echo "✅ 作成完了: $target_file"
done

echo ""
echo "🎉 すべての .env ファイルの展開が完了しました"
