# Hướng Dẫn Cấu Hình Google Sign-In cho Android

## 🎯 Tình trạng hiện tại:

✅ **ĐÃ CẤU HÌNH XONG:** Các file Gradle đã được sửa, SHA-1 đã lấy, code đã sẵn sàng  
⏳ **CẦN BẠN LÀM:** Thêm SHA-1 vào Firebase, download google-services.json, tạo OAuth Client ID

---

## 📋 HƯỚNG DẪN THỰC HIỆN:

### 🔐 Bước 1: Thêm SHA-1 vào Firebase (QUAN TRỌNG NHẤT!)

**Làm thủ công qua browser:**

1. Mở: https://console.firebase.google.com/project/flutter-firebase-5592b/settings/general
2. Cuộn xuống phần **Your apps**
3. Tìm Android app (biểu tượng 🤖)
4. Trong **SHA certificate fingerprints**, bấm **Add fingerprint**
5. Dán SHA-1: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
6. Bấm **Save**

**⚠️ Nếu không thêm SHA-1 này, Google Sign-In sẽ lỗi DEVELOPER_ERROR!**

---

### 📄 Bước 2: Download google-services.json

**Làm thủ công:**

1. Vẫn trong cùng trang Firebase Console
2. Bấm **Download google-services.json**
3. Lưu file vào: `android/app/google-services.json`

**⚠️ File này BẮT BUỘC phải có!**

---

### 🔑 Bước 3: Tạo Android OAuth Client ID

**Làm thủ công qua browser:**

1. Mở: https://console.cloud.google.com/apis/credentials?project=flutter-firebase-5592b
2. Bấm **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Chọn **Application type**: **Android**
4. Package name: `com.example.nhom11_giaodien`
5. SHA-1: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
6. Bấm **CREATE**

---

### 🧪 Bước 4: Test

**Chạy lệnh trong terminal:**

```bash
flutter clean
flutter pub get
flutter run
```

Sau đó thử đăng nhập bằng Google trên thiết bị Android.

---

## ✅ Checklist:

- [ ] Đã mở link Firebase Console và thêm SHA-1
- [ ] Đã download và đặt `google-services.json` vào `android/app/`
- [ ] Đã tạo Android OAuth Client ID trong Google Cloud Console
- [ ] Đã chạy `flutter clean` và `flutter pub get`
- [ ] Đã test đăng nhập Google trên Android

---

## 📝 Thông tin cần thiết:

| Thông tin | Giá trị |
|-----------|---------|
| **Project ID** | `flutter-firebase-5592b` |
| **Package name** | `com.example.nhom11_giaodien` |
| **SHA-1** | `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B` |
| **Client ID** | `905772912335-slflqvo23plqorc6qti04fgg2ifct2le.apps.googleusercontent.com` |

---

## 🔍 Link nhanh:

- Firebase Console: https://console.firebase.google.com/project/flutter-firebase-5592b
- Project Settings: https://console.firebase.google.com/project/flutter-firebase-5592b/settings/general
- Google Cloud Console: https://console.cloud.google.com/apis/credentials?project=flutter-firebase-5592b

---

## ❓ Nếu gặp lỗi:

### Lỗi DEVELOPER_ERROR (10):
→ Chưa thêm SHA-1 vào Firebase hoặc SHA-1 sai

### Lỗi: File google-services.json not found:
→ Chưa download hoặc đặt file vào đúng thư mục

### Lỗi: PlatformException(12500, ...):
→ Đã hủy đăng nhập, không phải lỗi

### Các lỗi khác:
→ Xem log: `adb logcat | grep -i google`

---

## 📚 Xem thêm:

- Chi tiết đầy đủ: `ANDROID_GOOGLE_SIGN_IN_SETUP.md`
- Hướng dẫn nhanh: `ANDROID_GOOGLE_SIGN_IN_QUICK_FIX.md`
- Tóm tắt: `ANDROID_SETUP_SUMMARY.md`


