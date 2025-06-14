#!/bin/bash

echo "=== Docker Container診断・修復スクリプト ==="

cd /Users/texia/bukiya

echo "1. 現在のコンテナ状態を確認..."
docker-compose ps

echo -e "\n2. ネットワーク状態を確認..."
docker network ls | grep bukiya

echo -e "\n3. PostgreSQLコンテナを再起動..."
docker-compose restart postgres

echo -e "\n4. PostgreSQLコンテナが起動するまで待機..."
sleep 10

echo -e "\n5. PostgreSQL接続テスト..."
docker-compose exec -T postgres pg_isready -U bukiya_user -d bukiya_game

echo -e "\n6. Redisコンテナを再起動..."
docker-compose restart redis

echo -e "\n7. Redis接続テスト..."
docker-compose exec -T redis redis-cli ping

echo -e "\n8. バックエンドコンテナを再起動..."
docker-compose restart backend

echo -e "\n9. 最終状態確認..."
docker-compose ps

echo -e "\n10. バックエンドログの最新10行を表示..."
docker-compose logs --tail=10 backend

echo -e "\n=== 修復完了 ==="
echo "http://localhost:8000/health でAPIの状態を確認してください"