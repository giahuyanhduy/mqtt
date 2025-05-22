// Một ứng dụng Node.js lấy giá từ topic MQTT và gửi đổi giá tới server qua HTTP POST vào thời gian được quy định
// npm install axios mqtt moment
/* payload:
[
  { "metro": 1, "price": 18200, "applyAt": "2025-05-21T19:57:00+07:00" },
  { "metro": 2, "price": 19300, "applyAt": "2025-05-21T19:58:00+07:00" },
  { "metro": 3, "price": 20400, "applyAt": "2025-05-21T19:59:00+07:00" }
]
*/

const mqtt = require('mqtt');
const axios = require('axios');
const moment = require('moment-timezone');

// ==== Cấu hình ====
const MQTT_BROKER = 'mqtt://broker.hivemq.com';
const MQTT_TOPIC = 'mitelai/price/update';
const POST_URL = 'http://localhost:6969/changePrice';
const MAX_RETRY = 20;
const RETRY_DELAY_MS = 5000;

let totalJobs = 0;
let completedJobs = 0;
let exitTimer = null;

// ==== Kết nối MQTT ====
const client = mqtt.connect(MQTT_BROKER);

function logWithTimestamp(...args) {
    const timestamp = moment().tz("Asia/Ho_Chi_Minh").format("YYYY-MM-DD HH:mm:ss");
    console.log(`[${timestamp}]`, ...args);
}

function warnWithTimestamp(...args) {
    const timestamp = moment().tz("Asia/Ho_Chi_Minh").format("YYYY-MM-DD HH:mm:ss");
    console.warn(`[${timestamp}]`, ...args);
}

function errorWithTimestamp(...args) {
    const timestamp = moment().tz("Asia/Ho_Chi_Minh").format("YYYY-MM-DD HH:mm:ss");
    console.error(`[${timestamp}]`, ...args);
}

function checkExitCondition() {
    if (completedJobs === totalJobs && totalJobs > 0) {
        logWithTimestamp(`[EXIT] Tất cả lệnh đổi giá đã thực hiện xong. Thoát chương trình.`);
        exitTimer = setTimeout(() => process.exit(0), 1000);
    }
}

client.on('connect', () => {
    logWithTimestamp(`[MQTT] Đã kết nối đến broker: ${MQTT_BROKER}`);
    client.subscribe(MQTT_TOPIC, (err) => {
        if (!err) {
            logWithTimestamp(`[MQTT] Đang lắng nghe topic: ${MQTT_TOPIC}`);
        } else {
            errorWithTimestamp(`[MQTT] Lỗi khi subscribe:`, err.message);
        }
    });
});

async function postWithRetry(payload, attempt = 1) {
    try {
        const response = await axios.post(POST_URL, payload);
        logWithTimestamp(`[HTTP] Gửi đổi giá metro ${payload.metro}:`, response.data);
    } catch (err) {
        if (attempt < MAX_RETRY) {
            warnWithTimestamp(`[HTTP] Lỗi khi POST (thử lần ${attempt}): ${err.message}. Sẽ thử lại sau ${RETRY_DELAY_MS}ms.`);
            setTimeout(() => postWithRetry(payload, attempt + 1), RETRY_DELAY_MS);
            return;
        } else {
            errorWithTimestamp(`[HTTP] Thất bại sau ${MAX_RETRY} lần gửi:`, payload);
        }
    }
    completedJobs++;
    checkExitCondition();
}

client.on('message', async (topic, message) => {
    logWithTimestamp(`[MQTT] Nhận được message từ ${topic}: ${message}`);

    try {
        const payload = JSON.parse(message.toString());

        const items = Array.isArray(payload) ? payload : [payload];
        totalJobs = items.length;

        for (const item of items) {
            const { metro, price, applyAt } = item;

            if (typeof metro !== 'number' || typeof price !== 'number') {
                warnWithTimestamp('[MQTT] Dữ liệu không hợp lệ:', item);
                completedJobs++;
                continue;
            }

            // Xử lý thời gian áp dụng (applyAt: ISO 8601 string hoặc giờ VN)
            if (applyAt) {
                const now = moment().tz("Asia/Ho_Chi_Minh");
                const scheduled = moment.tz(applyAt, "Asia/Ho_Chi_Minh");
                const delay = scheduled.diff(now);

                if (delay > 0) {
                    logWithTimestamp(`[SCHEDULED] Sẽ gửi đổi giá metro ${metro} lúc ${scheduled.format('HH:mm:ss')} (${delay} ms)`);
                    setTimeout(() => postWithRetry({ metro, price }), delay);
                    continue;
                }
            }

            // Gửi ngay nếu không có hoặc đã qua thời gian áp dụng
            await postWithRetry({ metro, price });
        }

    } catch (err) {
        errorWithTimestamp('[MQTT] Lỗi xử lý message:', err.message);
    }
});

