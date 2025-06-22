#!/bin/bash
set -e

echo "🛠️ Linter/Formatter 設定ファイルを生成中..."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# pyproject.toml
cat > "$ROOT_DIR/pyproject.toml" <<EOF
[tool.black]
line-length = 88
target-version = ["py39"]
include = '\.pyi?$'
exclude = '''
/(
    \.git
  | \.venv
  | build
  | dist
)/
'''

[tool.ruff]
line-length = 88
target-version = "py39"
exclude = ["venv", "tests"]
select = ["E", "F", "I", "W", "B", "C90"]
ignore = ["E501"]
EOF

# .eslintrc.json
cat > "$ROOT_DIR/.eslintrc.json" <<EOF
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
    "ecmaFeatures": { "jsx": true },
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "plugins": ["react", "@typescript-eslint"],
  "rules": {
    "semi": ["error", "always"],
    "quotes": ["error", "double"],
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": ["warn"],
    "react/react-in-jsx-scope": "off"
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
EOF

# .rustfmt.toml
cat > "$ROOT_DIR/.rustfmt.toml" <<EOF
max_width = 100
hard_tabs = false
tab_spaces = 4
edition = "2021"
use_small_heuristics = "Max"
normalize_doc_attributes = true
reorder_imports = true
format_code_in_doc_comments = true
EOF

echo "✅ 生成完了: Linter設定ファイル"
