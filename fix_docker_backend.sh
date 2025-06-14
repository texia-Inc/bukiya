#!/bin/bash

echo "=== Docker環境修正スクリプト ==="

# プロジェクトディレクトリに移動
cd /Users/texia/bukiya

echo "1. 既存のDockerコンテナを停止・削除..."
docker-compose down -v

echo "2. Dockerイメージの状態確認..."
docker ps -a

echo "3. Docker環境を再構築..."
docker-compose up -d

echo "4. コンテナ起動状況を確認..."
sleep 10
docker ps

echo "5. バックエンドログを確認..."
docker logs bukiya-backend --tail 20

echo "6. データベースログを確認..."
docker logs bukiya-postgres --tail 10

echo "7. API接続テスト..."
sleep 5
curl -f http://localhost:8000/health || echo "API接続失敗"

echo "=== 修正完了 ==="
echo ""
echo "実行方法:"
echo "chmod +x /Users/texia/bukiya/fix_docker_backend.sh"
echo "/Users/texia/bukiya/fix_docker_backend.sh"