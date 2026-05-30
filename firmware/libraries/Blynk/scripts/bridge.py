import os
import platform
import sys
import serial
import time
import socket

# --- 1. VÁ LỖI IPV6 (Dành cho Python 3.13) ---
# Ép hệ thống chỉ trả về địa chỉ IPv4 để tránh lỗi "must be a pair"
old_getaddrinfo = socket.getaddrinfo
def new_getaddrinfo(*args, **kwargs):
    responses = old_getaddrinfo(*args, **kwargs)
    return [r for r in responses if r[0] == socket.AF_INET]
socket.getaddrinfo = new_getaddrinfo

# --- 2. VÁ LỖI WINDOWS (os.uname) ---
if platform.system() == "Windows":
    class MockUname:
        def __getitem__(self, i):
            system_info = [platform.system(), platform.node(), platform.release(), platform.version(), platform.machine()]
            return system_info[i]
    os.uname = lambda: MockUname()

import BlynkLib 

# --- 3. CẤU HÌNH ---
BLYNK_AUTH = 'oGoU2EryohkWZqgzWgJx3_2D_vCq7TMc'
COM_PORT = 'COM6' 
BAUD_RATE = 9600

print("--- Đang kết nối với máy chủ Blynk IoT 2.0 (blynk.cloud) ---")

# Dùng server khu vực Singapore để nhanh và ổn định hơn cho Việt Nam
try:
    blynk = BlynkLib.Blynk(BLYNK_AUTH, server='sgp1.blynk.cloud', port=80)
except Exception as e:
    print(f"Lỗi khởi tạo Blynk: {e}")
    sys.exit()

# CẤU HÌNH CỔNG USB
try:
    arduino = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)
    print(f"✅ Đã kết nối thành công với Arduino tại {COM_PORT}")
    time.sleep(2) 
except Exception as e:
    print(f"❌ LỖI SERIAL: {e}")
    sys.exit()

# --- 4. XỬ LÝ LỆNH ---
@blynk.VIRTUAL_WRITE(0)
def v0_write_handler(value):
    try:
        goc_quay = value[0]
        lenh = f"{goc_quay}\n"
        arduino.write(lenh.encode('utf-8'))
        print(f"📱 App gửi lệnh: {goc_quay} độ")
    except Exception as e:
        print(f"⚠️ Lỗi gửi lệnh: {e}")

print("🚀 HỆ THỐNG ĐÃ SẴN SÀNG!")

while True:
    try:
        blynk.run()
    except Exception as e:
        print(f"Mất kết nối: {e}")
        time.sleep(5)
        break