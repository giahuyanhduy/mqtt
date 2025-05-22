#!/bin/bash

# Di chuyển đến thư mục /home
cd /home || exit 1

# Tải file mqtt.zip từ GitHub
wget https://github.com/giahuyanhduy/main/raw/mqtt.zip

# Giải nén file mqtt.zip vào thư mục hiện tại
unzip -o mqtt.zip

# Di chuyển vào thư mục MQTT (giả sử thư mục MQTT đã được tạo từ file zip)
cd /home/MQTT || exit 1

# Cài đặt các gói Node.js
npm install axios mqtt@4 moment moment-timezone

# Tạo hoặc cập nhật cron job để chạy script này mỗi 30 phút
(crontab -l 2>/dev/null; echo "*/30 * * * * /home/MQTT/run_app.sh") | crontab -

# Chạy ứng dụng (giả sử bạn có file chính là app.js, điều chỉnh nếu khác)
node app.js

echo "Tải về, giải nén, cài đặt và chạy ứng dụng thành công!"