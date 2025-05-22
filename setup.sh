#!/bin/bash

# Kiểm tra các công cụ cần thiết
if ! command -v curl &> /dev/null; then
    echo "Lỗi: curl không được cài đặt. Vui lòng cài đặt: sudo apt update && sudo apt install curl"
    exit 1
fi
if ! command -v node &> /dev/null; then
    echo "Lỗi: Node.js không được cài đặt. Vui lòng cài đặt: sudo apt update && sudo apt install nodejs"
    exit 1
fi
if ! command -v npm &> /dev/null; then
    echo "Lỗi: npm không được cài đặt. Vui lòng cài đặt: sudo apt update && sudo apt install npm"
    exit 1
fi

# Tạo thư mục /home/MQTT nếu chưa tồn tại
echo "Đang tạo thư mục /home/MQTT..."
mkdir -p /home/MQTT || { echo "Lỗi: Không thể tạo thư mục /home/MQTT. Kiểm tra quyền truy cập."; exit 1; }

# Di chuyển vào thư mục /home/MQTT
cd /home/MQTT || { echo "Lỗi: Không thể di chuyển vào thư mục /home/MQTT"; exit 1; }

# Tải file mqtt_update_price_new.js từ GitHub
echo "Đang tải file mqtt_update_price_new.js..."
curl -L -o mqtt_update_price_new.js https://raw.githubusercontent.com/giahuyanhduy/mqtt/main/mqtt_update_price_new.js

# Kiểm tra xem file mqtt_update_price_new.js đã được tải thành công hay chưa
if [ ! -f mqtt_update_price_new.js ]; then
    echo "Lỗi: Không thể tải file mqtt_update_price_new.js. Kiểm tra kết nối mạng hoặc URL."
    exit 1
fi

# Kiểm tra kích thước file để đảm bảo không rỗng
if [ ! -s mqtt_update_price_new.js ]; then
    echo "Lỗi: File mqtt_update_price_new.js rỗng hoặc bị hỏng. Xóa file và thử lại."
    rm -f mqtt_update_price_new.js
    exit 1
fi

# Tải file run_app.sh từ GitHub
echo "Đang tải file run_app.sh..."
curl -L -o run_app.sh https://raw.githubusercontent.com/giahuyanhduy/mqtt/main/run_app.sh

# Kiểm tra xem file run_app.sh đã được tải thành công hay chưa
if [ ! -f run_app.sh ]; then
    echo "Lỗi: Không thể tải file run_app.sh. Kiểm tra kết nối mạng hoặc URL."
    exit 1
fi

# Kiểm tra kích thước file để đảm bảo không rỗng
if [ ! -s run_app.sh ]; then
    echo "Lỗi: File run_app.sh rỗng hoặc bị hỏng. Xóa file và thử lại."
    rm -f run_app.sh
    exit 1
fi

# Cấp quyền thực thi cho run_app.sh
echo "Đang cấp quyền thực thi cho run_app.sh..."
chmod +x run_app.sh

# Cài đặt các gói Node.js
echo "Đang cài đặt các gói Node.js..."
npm install axios mqtt@4 moment moment-timezone

# Tạo hoặc cập nhật cron job để chạy run_app.sh mỗi 30 phút
echo "Đang thiết lập cron job..."
(crontab -l 2>/dev/null; echo "*/30 * * * * /home/MQTT/run_app.sh") | crontab -

# Chạy ứng dụng
echo "Đang chạy ứng dụng..."
node mqtt_update_price_new.js

# Kiểm tra kết quả chạy ứng dụng
if [ $? -ne 0 ]; then
    echo "Lỗi: Chạy node mqtt_update_price_new.js thất bại. Kiểm tra file mqtt_update_price_new.js."
    exit 1
fi

echo "Tải về, cài đặt và chạy ứng dụng thành công! (Thời gian: $(date))"
