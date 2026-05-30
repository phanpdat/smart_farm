#include "esp_camera.h"
#include <WiFi.h>
#include <WiFiClientSecure.h>

// ===========================
// 1. CẤU HÌNH WIFI & SERVER
// ===========================
const char* ssid = "HaveA GOodDay";
const char* password = "azertyuiop7";
const char* serverHost = "tomato-ai-server-isuz.onrender.com";
const char* serverPath = "/predict";

// ===========================
// 2. CHÂN PIN AI-THINKER 
// ===========================
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27
#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

void setup() {
  Serial.begin(115200);
  Serial.println("\n--- Khoi dong ESP32-CAM ---");

  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  
  config.pin_sccb_sda = SIOD_GPIO_NUM; 
  config.pin_sccb_scl = SIOC_GPIO_NUM;
  
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;

  if(psramFound()){
    config.frame_size = FRAMESIZE_VGA;
    config.jpeg_quality = 10;
    config.fb_count = 2;
    config.grab_mode = CAMERA_GRAB_LATEST;
  } else {
    config.frame_size = FRAMESIZE_SVGA;
    config.jpeg_quality = 12;
    config.fb_count = 1;
  }

  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed: 0x%x", err);
    return;
  }
  Serial.println("Camera OK!");

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    captureAndSend();
  }
  delay(15000); 
}

void captureAndSend() {
  camera_fb_t * fb = esp_camera_fb_get(); 
  if(!fb) {
    Serial.println("Capture failed");
    return;
  }

  WiFiClientSecure client;
  client.setInsecure();

  if (client.connect(serverHost, 443)) {
    Serial.println("Connected to Render!");

    String boundary = "ESP32CamBoundary";
    String head = "--" + boundary + "\r\nContent-Disposition: form-data; name=\"image\"; filename=\"capture.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n";
    String tail = "\r\n--" + boundary + "--\r\n";
    uint32_t totalLen = head.length() + fb->len + tail.length();

    client.print("POST " + String(serverPath) + " HTTP/1.1\r\n");
    client.print("Host: " + String(serverHost) + "\r\n");
    client.print("Content-Type: multipart/form-data; boundary=" + boundary + "\r\n");
    client.print("Content-Length: " + String(totalLen) + "\r\n");
    client.print("Connection: close\r\n\r\n");

    client.print(head);
    
    // Gui du lieu anh theo tung khoi 1024 byte
    uint8_t *fb_buf = fb->buf;
    size_t fb_len = fb->len;
    for (size_t n=0; n<fb_len; n=n+1024) {
      if (n+1024 < fb_len) {
        client.write(fb_buf, 1024);
        fb_buf += 1024;
      } else if (fb_len%1024 > 0) {
        client.write(fb_buf, fb_len%1024);
      }
    }
    
    client.print(tail);

    while (client.connected()) {
      String line = client.readStringUntil('\n');
      if (line == "\r") break;
    }
    Serial.println("Response: " + client.readString());
    
  } else {
    Serial.println("Connect failed!");
  }

  client.stop();
  esp_camera_fb_return(fb); 
}