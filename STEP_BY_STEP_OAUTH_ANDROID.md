# Hướng Dẫn Từng Bước: Tạo OAuth Client ID cho Android

## 🎯 Mục tiêu:

Tạo OAuth 2.0 Client ID cho Android trong Google Cloud Console để Google Sign-In hoạt động.

---

## 📊 BƯỚC 1: Mở Google Cloud Console

**👉 Click link này:**
https://console.cloud.google.com/apis/credentials?project=flutter-firebase-5592b

**Hoặc:**
1. Vào: https://console.cloud.google.com/
2. Click dropdown trên cùng → Chọn `flutter-firebase-5592b`

**📸 Bạn sẽ thấy:** Trang "Credentials" với các API keys, OAuth clients, etc.

---

## 📊 BƯỚC 2: Click nút Create Credentials

**👉 Tìm nút màu xanh:** **+ CREATE CREDENTIALS**

**📸 Bạn sẽ thấy:** Dropdown menu với các tùy chọn

---

## 📊 BƯỚC 3: Chọn OAuth client ID

**👉 Click:** **OAuth client ID** (dòng thứ hai trong dropdown)

**📸 Bạn sẽ thấy:** Popup "Create OAuth client ID"

---

## 📊 BƯỚC 4: Cấu hình OAuth Consent Screen (NẾU CẦN)

**⚠️ BẠN SẼ THẤY:**

### Trường hợp A: Có popup "Configure OAuth consent screen"
**👉 Làm theo:**

1. Click **External** → Click **CREATE**
2. Điền form:
   - **App name**: `Nhom11 Giaodien`
   - **User support email**: Chọn email của bạn
   - **Developer contact**: Email của bạn
3. Click **SAVE AND CONTINUE** (3 lần)
4. Click **BACK TO DASHBOARD**

### Trường hợp B: Không có popup
**👉 Skip** bước này → Làm tiếp Bước 5

---

## 📊 BƯỚC 5: Chọn Android

**👉 Trong popup "Create OAuth client ID":**

1. Tìm dropdown **Application type**
2. Click dropdown
3. Chọn **Android**

**📸 Bạn sẽ thấy:** Form hiển thị các trường cho Android

---

## 📊 BƯỚC 6: Điền thông tin

**👉 Điền 3 trường:**

### 1️⃣ Name:
```
Android App
```
*(Đặt tên gì cũng được)*

### 2️⃣ Package name:
```
com.example.nhom11_giaodien
```

**⚠️ PHẢI CHÍNH XÁC từ android/app/build.gradle.kts**

### 3️⃣ SHA-1 certificate fingerprint:
```
73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B
```

**⚠️ PHẢI CHÍNH XÁC**

---

## 📊 BƯỚC 7: Click Create

**👉 Click nút màu xanh:** **CREATE** (ở cuối popup)

**📸 Bạn sẽ thấy:** Popup "OAuth client created"

---

## 📊 BƯỚC 8: Hoàn thành

**📸 Popup hiển thị:**
```
OAuth client created

Your Client ID:
905772912335-xxxxx...xxxxx.apps.googleusercontent.com
```

**👉 Click:** **OK**

---

## ✅ XONG RỒI!

Bạn đã tạo xong OAuth Client ID cho Android!

---

## 🔍 Kiểm tra lại:

**👉 Trong trang Credentials:**

1. Scroll xuống phần **OAuth 2.0 Client IDs**
2. Tìm entry có **Type**: `Android`
3. Click vào để xem chi tiết

Bạn sẽ thấy:
- ✅ Package name: com.example.nhom11_giaodien
- ✅ SHA-1: 73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B

---

## 📋 Checklist Cuối Cùng:

- [ ] Đã vào trang Credentials
- [ ] Đã click **+ CREATE CREDENTIALS** → **OAuth client ID**
- [ ] Đã cấu hình OAuth consent screen (nếu cần)
- [ ] Đã chọn **Android**
- [ ] Đã nhập Package name: `com.example.nhom11_giaodien`
- [ ] Đã nhập SHA-1: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
- [ ] Đã click **CREATE**
- [ ] Đã thấy popup "OAuth client created"
- [ ] Đã click **OK**
- [ ] Đã kiểm tra lại trong danh sách

---

## ⚠️ NHỚ:

**Bạn KHÔNG cần:**
- ❌ Copy Client ID vào code
- ❌ Ghi nhớ Client ID
- ❌ Quản lý Client Secret

**Bạn CHỈ CẦN:**
- ✅ Tạo OAuth Client ID này trong Google Cloud Console
- ✅ Đảm bảo Package name và SHA-1 đúng

---

## 🎯 Tiếp theo:

Sau khi tạo xong, làm theo:
`CAN_BIET_ANDROID.md` để hoàn thành các bước còn lại.

---

## 📞 Cần giúp?

Xem thêm:
- `TAO_OAUTH_CLIENT_ID_ANDROID.md` - Hướng dẫn chi tiết
- `HUONG_DAN_ANDROID_GOOGLE_SIGNIN.md` - Tổng quan
- `CAN_BIET_ANDROID.md` - Checklist tổng thể


