#!/bin/bash

# Di chuyển đến thư mục /home
cd /home || exit

# Tải tệp mqtt.zip từ GitHub
curl -L -o /tmp/mqtt.zip https://github.com/giahuyanhduy/blog/main/mqtt.zip?raw=true

# Giải nén file mqtt.zip vào /home
unzip -o /tmp/mqtt.zip -d /home

# Di chuyển vào thư mục /home/MQTT (thư mục đã có sẵn trong file zip)
cd /home/MQTT || exit

# Cài đặt các gói Node.js
npm install axios mqtt@4 moment moment-timezone

# Tạo hoặc cập nhật cron job để chạy script này mỗi 30 phút
(crontab -l 2>/dev/null; echo "*/30 * * * * /home/MQTT/run_app.sh") | crontab -

# Chạy ứng dụng (giả sử bạn có file chính là app.js, điều chỉnh nếu khác)
node app.js

# Xóa tệp zip đã tải
rm /tmp/mqtt.zip

echo "Tải về, giải nén, cài đặt và chạy ứng dụng thành công!"