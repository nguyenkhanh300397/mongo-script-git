#!/bin/bash

# Thiết lập múi giờ
export TZ='Asia/Ho_Chi_Minh'

# Cấu hình
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
DUMP_DIR="/data/mongo-dump"
ARCHIVE_PATH="/data/mongo-dump-$TIMESTAMP.tar.gz"
REMOTE_USER="khanhn"
REMOTE_HOST="192.168.1.10"
REMOTE_DIR="/home/khanhn/mongo_backups2"

# Tạo dump
mongodump --host localhost --port 27018 --out "$DUMP_DIR"
if [ $? -ne 0 ]; then
  echo "❌ Mongodump thất bại!"
  exit 1
fi

# Nén lại
tar -czf "$ARCHIVE_PATH" -C "$DUMP_DIR" .
if [ $? -ne 0 ]; then
  echo "❌ Nén dữ liệu thất bại!"
  exit 1
fi

# Tạo thư mục trên máy remote nếu chưa tồn tại
ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_DIR"
if [ $? -ne 0 ]; then
  echo "❌ Không thể tạo thư mục trên máy remote!"
  exit 1
fi

# Gửi file nén qua máy remote
scp "$ARCHIVE_PATH" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"
if [ $? -ne 0 ]; then
  echo "❌ Gửi file backup thất bại!"
  exit 1
fi

echo "✅ Gửi file backup thành công!"

