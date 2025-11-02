# Hướng Dẫn Cấu Hình Google Sign-In cho Android

## ⚠️ Khác với Web:
Trên Android, Google Sign-In cần cấu hình **SHA-1 Certificate Fingerprint** trong Google Cloud Console, KHÔNG phải chỉ thêm Client ID vào code.

## Các bước cấu hình:

### Bước 1: Lấy SHA-1 Fingerprint

#### Cách 1: Dùng Gradle (Khuyến nghị)
1. Mở terminal trong thư mục project
2. Chạy lệnh:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   (Trên Windows: `gradlew.bat signingReport`)

3. Tìm phần **Variant: debug** hoặc **release**
4. Copy dòng **SHA1:** (có dạng: `XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX`)

### ✅ SHA-1 của bạn:
```
73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B
```

**Copy SHA-1 này để dùng ở bước tiếp theo!**

#### Cách 2: Dùng keytool
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
(Trên Windows: `%USERPROFILE%\.android\debug.keystore`)

### Bước 2: Thêm SHA-1 vào Firebase

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project: **flutter-firebase-5592b**
3. Vào **Project Settings** (biểu tượng bánh răng)
4. Scroll xuống phần **Your apps**
5. Chọn **Android app** (biểu tượng Android 🤖)
6. Trong phần **SHA certificate fingerprints**, click **Add fingerprint**
7. Paste SHA-1 fingerprint đã lấy ở Bước 1
8. Click **Save**

### Bước 3: Đảm bảo có file google-services.json

1. Firebase Console → **Project Settings** → **Your apps** → **Android app**
2. Download file **google-services.json**
3. Copy file vào thư mục: `android/app/google-services.json`

### Bước 4: Cấu hình build.gradle.kts

Mở file `android/app/build.gradle.kts` và đảm bảo có:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ← THÊM DÒNG NÀY
}

// ... existing code ...

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation(platform("com.google.firebase:firebase-bom:32.7.0")) // ← THÊM
}
```

Và trong file `android/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application") version "8.1.0"
    // ... existing plugins ...
    id("com.google.gms.google-services") version "4.4.0" apply false // ← THÊM
}
```

### Bước 5: Cấu hình Android OAuth Client ID

1. Vào [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project: **flutter-firebase-5592b**
3. Vào **APIs & Services** → **Credentials**
4. Tìm hoặc tạo **OAuth 2.0 Client ID** cho Android
5. Nếu chưa có:
   - Click **+ CREATE CREDENTIALS** → **OAuth client ID**
   - Chọn **Application type**: **Android**
   - Package name: `com.example.nhom11_giaodien`
   - SHA-1 certificate fingerprint: Paste SHA-1 đã lấy ở Bước 1
   - Click **CREATE**

### Bước 6: Đảm bảo Google Sign-In API đã bật

1. Google Cloud Console → **APIs & Services** → **Library**
2. Tìm và bật:
   - **Google Sign-In API**
   - **Identity Toolkit API**

### Bước 7: Code đã sẵn sàng

Code trong `lib/login_screen.dart` đã có Client ID:
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '905772912335-slflqvo23plqorc6qti04fgg2ifct2le.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
);
```

**Lưu ý:** Trên Android, có thể KHÔNG CẦN truyền `clientId` vào GoogleSignIn constructor vì Firebase sẽ tự động lấy từ google-services.json. Nhưng có cũng không sao.

### Bước 8: Test trên Android

1. Clean và rebuild project:
   ```bash
   flutter clean
   flutter pub get
   cd android
   ./gradlew clean
   cd ..
   flutter run
   ```

2. Thử đăng nhập bằng Google trên Android device/emulator

## Kiểm tra nếu vẫn lỗi:

### Lỗi 10: "DEVELOPER_ERROR"
- Chưa thêm SHA-1 vào Firebase
- SHA-1 không đúng

### Lỗi 12500: "Sign in cancelled"
- Đã cancel, không phải lỗi

### Lỗi khác:
- Kiểm tra internet connection
- Kiểm tra Google Play Services đã cài đặt trên thiết bị
- Xem log: `adb logcat | grep -i google`

## Tóm tắt checklist:

- [ ] Đã lấy SHA-1 fingerprint
- [ ] Đã thêm SHA-1 vào Firebase Console
- [ ] Đã download và đặt `google-services.json` vào `android/app/`
- [ ] Đã thêm Google Services plugin vào `build.gradle.kts`
- [ ] Đã tạo/kiểm tra OAuth 2.0 Client ID cho Android trong Google Cloud Console
- [ ] Đã bật Google Sign-In API trong Google Cloud Console
- [ ] Đã clean và rebuild project
- [ ] Đã test trên thiết bị Android

