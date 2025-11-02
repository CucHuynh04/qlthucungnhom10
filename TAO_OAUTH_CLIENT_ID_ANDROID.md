# Hướng Dẫn Tạo OAuth 2.0 Client ID cho Android

## 📋 Thông tin cần chuẩn bị:

- **Project ID**: `flutter-firebase-5592b`
- **Package name**: `com.example.nhom11_giaodien`
- **SHA-1**: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`

---

## 🚀 Các bước thực hiện:

### Bước 1: Truy cập Google Cloud Console

👉 Mở link trực tiếp: https://console.cloud.google.com/apis/credentials?project=flutter-firebase-5592b

**Hoặc:**

1. Mở trình duyệt và vào: https://console.cloud.google.com/
2. Ở trên cùng, click dropdown chọn project → Chọn **flutter-firebase-5592b**

![Chọn project](https://console.cloud.google.com/)

---

### Bước 2: Điều hướng đến Credentials

**Trên menu bên trái:**

1. Click vào **APIs & Services** (APIs & Dịch vụ)
2. Click vào **Credentials** (Thông tin xác thực)

**Hoặc:** Dùng link trực tiếp ở Bước 1

Bạn sẽ thấy trang "Credentials" với danh sách các API keys, OAuth client IDs, etc.

---

### Bước 3: Tạo OAuth Client ID

1. Ở trên cùng trang, click nút **+ CREATE CREDENTIALS** (Tạo thông tin xác thực)
2. Chọn **OAuth client ID** từ dropdown menu

![Create Credentials](https://i.imgur.com/example.png)

---

### Bước 4: Cấu hình OAuth Consent Screen (NẾU CHƯA CÓ)

**⚠️ Nếu bạn thấy popup hỏi về "OAuth consent screen", làm theo:**

1. Chọn **External** (Bên ngoài) → Click **CREATE**
2. Nhập thông tin:
   - **App name**: `Nhom11 Giaodien` (hoặc tên bạn muốn)
   - **User support email**: Chọn email của bạn
   - **Developer contact information**: Email của bạn
3. Click **SAVE AND CONTINUE** cho các bước tiếp theo
4. Cuối cùng click **BACK TO DASHBOARD**

**Nếu KHÔNG thấy popup này** → Skip bước này và làm tiếp Bước 5

---

### Bước 5: Chọn Application Type

Trong popup "Create OAuth client ID", bạn sẽ thấy dropdown **Application type**:

1. Click dropdown **Application type**
2. Chọn **Android** từ danh sách

---

### Bước 6: Nhập thông tin Android App

Điền form với thông tin sau:

#### 1. Name (Tên):
```
Android - Nhom11 Giaodien
```
*(Tên này là tên hiển thị cho OAuth Client ID, bạn có thể đặt tên khác)*

#### 2. Package name (Tên gói):
```
com.example.nhom11_giaodien
```
**⚠️ Phải CHÍNH XÁC từ build.gradle.kts!**

#### 3. SHA-1 certificate fingerprint:
```
73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B
```
**⚠️ Phải CHÍNH XÁC với SHA-1 đã lấy!**

---

### Bước 7: Tạo Client ID

1. Kiểm tra lại các thông tin đã nhập
2. Click nút **CREATE** ở cuối popup

---

### Bước 8: Lưu Client ID (Tùy chọn)

Sau khi tạo, bạn sẽ thấy popup hiển thị:

**OAuth client created**

Với thông tin:
- **Your Client ID**: `905772912335-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com`
- **Your Client Secret**: (*không có cho Android*)

**⚠️ Lưu ý:** 
- Bạn KHÔNG CẦN Client ID này trong code Android!
- Android sẽ tự động lấy Client ID từ `google-services.json`
- Nhưng cần có OAuth Client ID này trong Google Cloud Console để Google Sign-In hoạt động

Nếu muốn, bạn có thể click **DOWNLOAD JSON** hoặc copy Client ID để lưu lại.

Click **OK** để đóng popup.

---

## ✅ Hoàn thành!

Bạn đã tạo xong OAuth 2.0 Client ID cho Android!

---

## 🔍 Kiểm tra lại:

Để xem OAuth Client ID vừa tạo:

1. Vẫn trong trang **Credentials**
2. Scroll xuống phần **OAuth 2.0 Client IDs**
3. Tìm entry có:
   - **Type**: Android
   - **Package name**: com.example.nhom11_giaodien
   - **SHA-1 certificate fingerprint**: 73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B

---

## 📝 Checklist:

- [ ] Đã chọn project `flutter-firebase-5592b`
- [ ] Đã vào trang **APIs & Services** → **Credentials**
- [ ] Đã click **+ CREATE CREDENTIALS** → **OAuth client ID**
- [ ] Đã cấu hình OAuth consent screen (nếu cần)
- [ ] Đã chọn Application type: **Android**
- [ ] Đã nhập Package name: `com.example.nhom11_giaodien`
- [ ] Đã nhập SHA-1: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
- [ ] Đã click **CREATE**
- [ ] Đã thấy popup "OAuth client created"

---

## ⚠️ Lưu ý quan trọng:

### 1. KHÔNG cần thêm Client ID vào code!
Android app sẽ **TỰ ĐỘNG** lấy Client ID từ file `google-services.json`. Bạn KHÔNG cần copy/paste Client ID vào code Dart.

### 2. KHÔNG có Client Secret
Android OAuth Client ID **không có** Client Secret (khác với Web Client ID).

### 3. Cần đúng Package name
Package name phải **CHÍNH XÁC** giống trong `android/app/build.gradle.kts`:
```kotlin
applicationId = "com.example.nhom11_giaodien"
```

### 4. Cần đúng SHA-1
SHA-1 phải **CHÍNH XÁC** giống với debug keystore bạn đang dùng.

---

## ❓ Nếu gặp lỗi:

### Lỗi: "The OAuth client was not created"
→ Kiểm tra lại Package name và SHA-1 có đúng không

### Lỗi: "Package name already exists"
→ Có thể đã có OAuth Client ID cho Android, kiểm tra trong danh sách

### Lỗi: "Invalid SHA-1 format"
→ SHA-1 phải có định dạng: `XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX`

### Lỗi: Permission denied
→ Đảm bảo bạn có quyền Editor hoặc Owner trên project

---

## 🎯 Tiếp theo:

Sau khi tạo xong OAuth Client ID:

1. ✅ Đảm bảo đã thêm SHA-1 vào Firebase (Bước 1 trong CAN_BIET_ANDROID.md)
2. ✅ Đảm bảo đã có `google-services.json` (Bước 2 trong CAN_BIET_ANDROID.md)
3. ✅ Đã tạo OAuth Client ID (Bước này)
4. 🧪 Test: `flutter clean && flutter pub get && flutter run`

---

## 🔗 Xem thêm:

- Tài liệu chính thức: https://support.google.com/cloud/answer/6158849
- Hướng dẫn đầy đủ: `CAN_BIET_ANDROID.md`
- Hướng dẫn nhanh: `HUONG_DAN_ANDROID_GOOGLE_SIGNIN.md`


