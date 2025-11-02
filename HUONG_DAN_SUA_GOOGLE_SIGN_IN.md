# Hướng dẫn sửa lỗi Google Sign-In (ApiException: 10)

Lỗi `ApiException: 10` (DEVELOPER_ERROR) xảy ra khi:
- SHA-1/SHA-256 fingerprint chưa được thêm vào Google Cloud Console
- OAuth 2.0 Client ID cho Android chưa được cấu hình đúng
- Package name không khớp

## Bước 1: Lấy SHA-1 và SHA-256 fingerprint

### Trên Windows (PowerShell):
```powershell
cd android
./gradlew signingReport
```

Hoặc nếu đã có keystore:
```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### Trên macOS/Linux:
```bash
cd android
./gradlew signingReport
```

Hoặc:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Bạn sẽ thấy output như:
```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

## Bước 2: Thêm fingerprint vào Firebase Console

**Fingerprint của bạn:**
- **SHA-1**: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
- **SHA-256**: `79:88:97:0E:BD:25:20:AF:37:DB:B5:C9:C5:30:D1:83:90:56:E9:4B:36:3B:50:46:54:AB:77:C0:9A:FB:4F:00`

### Cách 1: Nếu app Android đã tồn tại trong Firebase (package: `com.example.vandung5_dinhngocnang`)

1. Mở [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Project Settings** (⚙️)
4. Scroll xuống phần **Your apps**
5. Chọn app Android với package: `com.example.vandung5_dinhngocnang`
6. Click **Add fingerprint**
7. Thêm cả **SHA-1** và **SHA-256** fingerprint ở trên
8. Download lại file `google-services.json` và thay thế file cũ trong `android/app/`

### Cách 2: Nếu chưa có app Android hoặc package name không khớp

**Vấn đề hiện tại:** 
- Package trong `google-services.json`: `com.example.firebase_auth_demo`
- Package trong `build.gradle.kts`: `com.example.vandung5_dinhngocnang`
- **Chúng không khớp!**

**Giải pháp:**

#### Option A: Tạo app Android mới trong Firebase Console

1. Vào [Firebase Console](https://console.firebase.google.com/) > Project Settings
2. Click **Add app** > Chọn **Android**
3. Đăng ký app:
   - **Package name**: `com.example.vandung5_dinhngocnang` (phải khớp với `applicationId` trong `build.gradle.kts`)
   - **App nickname** (tùy chọn): "Pet Manager Android"
   - **Debug signing certificate SHA-1**: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
4. Download file `google-services.json` mới
5. Thay thế file cũ trong `android/app/google-services.json`

#### Option B: Sửa package name trong build.gradle.kts (KHÔNG KHUYẾN NGHỊ)

Nếu muốn dùng package cũ `com.example.firebase_auth_demo`, sửa `applicationId` trong `build.gradle.kts`.

## Bước 3: Enable Google Sign-In trong Firebase Authentication

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Authentication** > **Sign-in method**
4. Tìm **Google** và click vào
5. **Enable** Google Sign-In nếu chưa bật
6. Nhập **Support email** (email của bạn)
7. Click **Save**

**Lưu ý:** OAuth 2.0 Client ID sẽ được tạo tự động khi bạn thêm fingerprint vào Firebase Console. Không cần tạo thủ công trong Google Cloud Console.

## Bước 4: Kiểm tra lại code

File `login_screen.dart` đã được cập nhật để không cần `clientId` trên Android (sẽ tự động lấy từ `google-services.json`).

## Bước 5: Rebuild app

```bash
flutter clean
flutter pub get
flutter run
```

## Lưu ý:

- **Debug keystore**: Vị trí mặc định:
  - Windows: `%USERPROFILE%\.android\debug.keystore`
  - macOS/Linux: `~/.android/debug.keystore`
  - Password: `android`

- **Release keystore**: Nếu bạn đã tạo release keystore, cần thêm SHA-1/SHA-256 của release keystore vào Firebase Console.

- Nếu vẫn lỗi, kiểm tra:
  - Package name trong `build.gradle.kts` phải khớp với Firebase Console
  - File `google-services.json` phải đúng và được đặt trong `android/app/`
  - Đã enable **Google Sign-In** trong Firebase Authentication

