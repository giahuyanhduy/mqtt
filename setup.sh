#!/bin/bash

# Kiểm tra xem curl có được cài đặt hay không
if ! command -v curl &> /dev/null; then
    echo "Lỗi: curl không được cài đặt. Vui lòng cài đặt: sudo apt update && sudo apt install curl"
    exit 1
fi

# Kiểm tra xem unzip có được cài đặt hay không
if ! command -v unzip &> /dev/null; then
    echo "Lỗi: unzip không được cài đặt. Vui lòng cài đặt: sudo apt update && sudo apt install unzip"
    exit 1
fi

# Kiểm tra xem Node.js có được cài đặt hay không
if ! command -v node &> /dev/null; then
    echo "Lỗi: Node.js không được cài đặt. Vui lòng cài đặt: sudo apt update && sudo apt install nodejs"
    exit 1
fi

# Di chuyển đến thư mục /home
cd /home || { echo "Lỗi: Không thể di chuyển vào thư mục /home. Kiểm tra quyền truy cập."; exit 1; }

# Tải tệp mqtt.zip từ GitHub
echo "Đang tải file mqtt.zip..."
curl -L -o /tmp/mqtt.zip https://github.com/giahuyanhduy/blog/raw/main/mqtt.zip

# Kiểm tra xem file mqtt.zip đã được tải thành công hay chưa
if [ ! -f /tmp/mqtt.zip ]; then
    echo "Lỗi: Không thể tải file /tmp/mqtt.zip. Kiểm tra kết nối mạng hoặc URL."
    exit 1
fi

# Kiểm tra kích thước file để đảm bảo không rỗng
if [ ! -s /tmp/mqtt.zip ]; then
    echo "Lỗi: File /tmp/mqtt.zip rỗng hoặc bị hỏng. Xóa file và thử lại."
    rm -f /tmp/mqtt.zip
    exit 1
fi

# Giải nén file mqtt.zip vào /home
echo "Đang giải nén file mqtt.zip..."
unzip -o /tmp/mqtt.zip -d /home

# Kiểm tra xem thư mục MQTT có tồn tại sau khi giải nén không
if [ ! -d /home/MQTT ]; then
    echo "Lỗi: Thư mục /home/MQTT không tồn tại sau khi giải nén. Kiểm tra nội dung file mqtt.zip."
    ls -la /home  # Hiển thị nội dung thư mục /home để debug
    exit 1
fi

# Di chuyển vào thư mục /home/MQTT
cd /home/MQTT || { echo "Lỗi: Không thể di chuyển vào thư mục /home/MQTT"; exit 1; }

# Cài đặt các gói Node.js
echo "Đang cài đặt các gói Node.js..."
npm install axios mqtt@4 moment moment-timezone

# Tạo hoặc cập nhật cron job để chạy script này mỗi 30 phút
echo "Đang thiết lập cron job..."
(crontab -l 2>/dev/null; echo "*/30 * * * * /home/MQTT/run_app.sh") | crontab -

# Chạy ứng dụng (giả sử bạn có file chính là app.js, điều chỉnh nếu khác)
echo "Đang chạy ứng dụng..."
node app.js

# Kiểm tra kết quả chạy ứng dụng (nếu thất bại, hiển thị lỗi)
if [ $? -ne 0 ]; then
    echo "Lỗi: Chạy node app.js thất bại. Kiểm tra file app.js."
    exit 1
fi

# Xóa tệp zip đã tải
rm /tmp/mqtt.zip

echo "Tải về, giải nén, cài đặt và chạy ứng dụng thành công! (Thời gian: $(date))"