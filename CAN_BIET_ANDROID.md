# ⚠️ CẦN BIẾT: Android Google Sign-In Chưa Hoạt Động

## 🎯 Vấn đề:

Trên **Web đã có Client ID** trong `web/index.html`, nhưng trên **Android cần cấu hình thêm** SHA-1 fingerprint.

## ✅ Đã làm xong:

1. ✅ Đã lấy SHA-1: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
2. ✅ Đã sửa file Gradle để thêm Google Services plugin
3. ✅ Code đã có Client ID sẵn

## ⏳ Bạn cần làm 3 việc:

### 1️⃣ Thêm SHA-1 vào Firebase

👉 Mở link: https://console.firebase.google.com/project/flutter-firebase-5592b/settings/general

- Scroll xuống **Your apps** → Android app
- Click **Add fingerprint** trong phần SHA certificate fingerprints
- Dán: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
- Click **Save**

### 2️⃣ Download google-services.json

👉 Vẫn trong trang Firebase đó

- Click **Download google-services.json**
- Copy file vào: `android/app/google-services.json`

### 3️⃣ Tạo Android OAuth Client ID

👉 Xem hướng dẫn chi tiết: **`STEP_BY_STEP_OAUTH_ANDROID.md`**

**Tóm tắt:**
- Mở link: https://console.cloud.google.com/apis/credentials?project=flutter-firebase-5592b
- Click **+ CREATE CREDENTIALS** → **OAuth client ID**
- Application type: **Android**
- Package name: `com.example.nhom11_giaodien`
- SHA-1: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
- Click **CREATE**

## 🧪 Sau đó test:

```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Xem hướng dẫn chi tiết:

👉 **`STEP_BY_STEP_OAUTH_ANDROID.md`** - Hướng dẫn từng bước với hình ảnh  
👉 `TAO_OAUTH_CLIENT_ID_ANDROID.md` - Hướng dẫn đầy đủ chi tiết  
👉 `HUONG_DAN_ANDROID_GOOGLE_SIGNIN.md` - Tổng quan tất cả các bước

