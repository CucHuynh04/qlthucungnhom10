# Hướng dẫn khắc phục lỗi đăng nhập

## Vấn đề 1: Đăng nhập Email/Password - "invalid-credential"

**Nguyên nhân:** Tài khoản chưa được tạo trong Firebase Authentication.

**Giải pháp:**

### Cách 1: Đăng ký tài khoản mới
1. Trong app, click vào **"Chưa có tài khoản? Đăng ký"** ở cuối màn hình đăng nhập
2. Điền thông tin:
   - Email: ví dụ `ngkhai@gmail.com`
   - Mật khẩu: tối thiểu 6 ký tự
3. Click **Đăng ký**
4. Sau khi đăng ký thành công, quay lại màn hình đăng nhập và đăng nhập

### Cách 2: Tạo tài khoản trong Firebase Console
1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Authentication** > **Users**
4. Click **Add user**
5. Nhập email và mật khẩu
6. Click **Add**

Sau đó đăng nhập bằng email/password đã tạo.

---

## Vấn đề 2: Đăng nhập Google - "ApiException: 10" (DEVELOPER_ERROR)

**Nguyên nhân:** SHA-1 fingerprint chưa được thêm vào Firebase Console cho package `com.example.vandung5_dinhngocnang`.

**Giải pháp:**

### Bước 1: Kiểm tra package name trong google-services.json

File `android/app/google-services.json` hiện có 2 packages:
- `com.example.firebase_auth_demo` (có OAuth client ID Android)
- `com.example.vandung5_dinhngocnang` (KHÔNG có OAuth client ID Android - chỉ có Web)

### Bước 2: Thêm SHA-1 fingerprint vào Firebase Console

**Fingerprint của bạn:**
- **SHA-1**: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
- **SHA-256**: `79:88:97:0E:BD:25:20:AF:37:DB:B5:C9:C5:30:D1:83:90:56:E9:4B:36:3B:50:46:54:AB:77:C0:9A:FB:4F:00`

#### Cách thực hiện:

1. **Mở Firebase Console:**
   - Vào [Firebase Console](https://console.firebase.google.com/)
   - Chọn project: `flutter-firebase-5592b`

2. **Vào Project Settings:**
   - Click vào biểu tượng ⚙️ (Settings) bên cạnh "Project Overview"
   - Hoặc vào **Project Settings**

3. **Tìm app Android:**
   - Scroll xuống phần **Your apps**
   - Tìm app Android có package name: `com.example.vandung5_dinhngocnang`
   - Nếu chưa có, xem **Bước 3**

4. **Thêm SHA-1 fingerprint:**
   - Click vào app Android `com.example.vandung5_dinhngocnang`
   - Tìm phần **SHA certificate fingerprints**
   - Click nút **Add fingerprint**
   - Dán SHA-1: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
   - Click **Save**

5. **Thêm SHA-256 (tùy chọn nhưng khuyến nghị):**
   - Click **Add fingerprint** lần nữa
   - Dán SHA-256: `79:88:97:0E:BD:25:20:AF:37:DB:B5:C9:C5:30:D1:83:90:56:E9:4B:36:3B:50:46:54:AB:77:C0:9A:FB:4F:00`
   - Click **Save**

6. **Download lại google-services.json:**
   - Trong cùng trang Project Settings
   - Scroll xuống phần **Your apps**
   - Click vào icon download ⬇️ bên cạnh app Android
   - Download file `google-services.json`
   - **Thay thế** file cũ trong `android/app/google-services.json`

### Bước 3: Nếu app Android chưa tồn tại trong Firebase

1. Trong Firebase Console > Project Settings > Your apps
2. Click **Add app** > Chọn **Android**
3. Điền thông tin:
   - **Package name**: `com.example.vandung5_dinhngocnang`
   - **App nickname** (tùy chọn): "Pet Manager Android"
   - **Debug signing certificate SHA-1**: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
4. Click **Register app**
5. Download file `google-services.json` mới
6. Thay thế file cũ trong `android/app/google-services.json`

### Bước 4: Enable Google Sign-In

1. Trong Firebase Console
2. Vào **Authentication** > **Sign-in method**
3. Tìm **Google** và click vào
4. Bật **Enable** (nếu chưa bật)
5. Nhập **Support email** (email của bạn)
6. Click **Save**

### Bước 5: Rebuild app

Sau khi đã cập nhật `google-services.json`:

```bash
flutter clean
flutter pub get
flutter run
```

---

## Kiểm tra sau khi sửa

### Đăng nhập Email/Password:
1. Đảm bảo đã đăng ký tài khoản
2. Nhập đúng email và mật khẩu
3. Click **ĐĂNG NHẬP**

### Đăng nhập Google:
1. Đảm bảo đã thêm SHA-1 fingerprint vào Firebase Console
2. Đảm bảo đã download lại `google-services.json` mới
3. Đảm bảo Google Sign-In đã được enable trong Firebase Authentication
4. Click **Đăng nhập bằng Google**
5. Chọn tài khoản Google của bạn

---

## Lưu ý quan trọng

- **SHA-1 fingerprint phải được thêm vào Firebase Console** để Google Sign-In hoạt động
- **File google-services.json phải được cập nhật** sau khi thêm fingerprint
- **Package name phải khớp** giữa `build.gradle.kts` và Firebase Console
- **Google Sign-In phải được enable** trong Firebase Authentication

## Nếu vẫn còn lỗi

1. Kiểm tra lại SHA-1 fingerprint bằng lệnh:
   ```bash
   cd android
   ./gradlew signingReport
   ```

2. Đảm bảo package name trong `build.gradle.kts` là:
   ```kotlin
   applicationId = "com.example.vandung5_dinhngocnang"
   ```

3. Kiểm tra file `google-services.json` có chứa OAuth client với:
   - `package_name`: `com.example.vandung5_dinhngocnang`
   - `client_type`: `1` (Android)
   - `certificate_hash`: SHA-1 (không có dấu `:`)

4. Thử xóa app và cài lại:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```


