#!/bin/bash

echo "=== バックエンド修正スクリプト開始 ==="

# 1. ポート8000を使用しているプロセスを強制終了
echo "1. ポート8000のプロセスを確認・終了中..."
lsof -ti:8000 | xargs kill -9 2>/dev/null || echo "ポート8000に実行中のプロセスはありません"

# 2. バックエンドディレクトリに移動
echo "2. バックエンドディレクトリに移動..."
cd /Users/texia/bukiya/backend

# 3. Pythonのバージョンを確認
echo "3. Python環境を確認..."
python --version
which python

# 4. 依存関係を強制インストール
echo "4. 依存関係をインストール中..."
pip install --force-reinstall passlib[bcrypt]==1.7.4
pip install --force-reinstall python-jose[cryptography]==3.3.0
pip install --force-reinstall fastapi==0.104.1
pip install --force-reinstall uvicorn[standard]==0.24.0

# 5. 全体の依存関係をインストール
echo "5. 全依存関係をインストール中..."
pip install -r requirements.txt

# 6. インストール状況を確認
echo "6. 重要なパッケージのインストール状況を確認..."
python -c "import passlib; print('passlib: OK')" 2>/dev/null || echo "passlib: NG"
python -c "import jose; print('python-jose: OK')" 2>/dev/null || echo "python-jose: NG"
python -c "import fastapi; print('fastapi: OK')" 2>/dev/null || echo "fastapi: NG"

# 7. サーバーの起動テスト
echo "7. サーバーの起動テスト..."
echo "uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 を実行してサーバーを起動してください"

echo "=== 修正スクリプト完了 ==="
echo ""
echo "次に実行するコマンド:"
echo "chmod +x /Users/texia/bukiya/fix_backend_now.sh"
echo "/Users/texia/bukiya/fix_backend_now.sh"
echo ""
echo "その後、バックエンドを起動:"
echo "cd /Users/texia/bukiya/backend"
echo "uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"