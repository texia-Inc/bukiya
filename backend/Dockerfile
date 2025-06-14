FROM python:3.11-slim

# 作業ディレクトリを設定
WORKDIR /app

# システムの依存関係をインストール
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Pythonの依存関係をコピーしてインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションコードをコピー
COPY . .

# 静的ファイル用ディレクトリを作成
RUN mkdir -p /app/static/images/weapons && \
    chown -R 1000:1000 /app/static && \
    chmod -R 755 /app/static

# ポート8000を公開
EXPOSE 8000

# アプリケーションを起動
CMD ["sh", "-c", "python startup_debug.py && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"]
