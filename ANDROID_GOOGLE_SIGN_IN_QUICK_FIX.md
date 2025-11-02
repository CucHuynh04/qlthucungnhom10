# Cấu Hình Nhanh Google Sign-In cho Android

## ✅ Đã hoàn thành:
- SHA-1 fingerprint đã lấy: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
- Client ID trong code đã có: `905772912335-slflqvo23plqorc6qti04fgg2ifct2le.apps.googleusercontent.com`

## 🔧 Cần làm thêm 3 bước:

### Bước 1: Thêm SHA-1 vào Firebase (QUAN TRỌNG NHẤT!)

1. Mở: https://console.firebase.google.com/project/flutter-firebase-5592b/settings/general
2. Scroll xuống phần **Your apps** → Tìm Android app (🤖)
3. Trong **SHA certificate fingerprints**, click **Add fingerprint**
4. Paste: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
5. Click **Save**

### Bước 2: Download google-services.json

1. Trong cùng trang Firebase (Project Settings)
2. Click **Download google-services.json**
3. Lưu file vào: `android/app/google-services.json`

### Bước 3: Thêm Google Services plugin

Cần sửa file `android/app/build.gradle.kts`:

**Tìm dòng 1-6:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
```

**Sửa thành:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
```

Và thêm vào cuối phần `dependencies` (sau dòng 54):
```kotlin
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
}
```

**Cũng cần sửa `android/build.gradle.kts`:**

Tìm file `android/build.gradle.kts` và sửa phần `pluginManagement`:
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

### Bước 4: Tạo Android OAuth Client ID (Nếu chưa có)

1. Mở: https://console.cloud.google.com/apis/credentials?project=flutter-firebase-5592b
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Chọn **Application type**: **Android**
4. Package name: `com.example.nhom11_giaodien`
5. SHA-1: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
6. Click **CREATE**

### Bước 5: Test

```bash
cd ..
flutter clean
flutter pub get
flutter run
```

## ⚠️ Lưu ý:

- Bước 1 là **BẮT BUỘC** - không có SHA-1 thì Google Sign-In sẽ lỗi DEVELOPER_ERROR
- File `google-services.json` là **BẮT BUỘC** - Firebase không hoạt động nếu thiếu file này
- Sau khi sửa, phải **flutter clean** và rebuild lại

## Kiểm tra checklist:

- [ ] Đã thêm SHA-1 vào Firebase
- [ ] Đã download `google-services.json` vào `android/app/`
- [ ] Đã thêm `id("com.google.gms.google-services")` vào `android/app/build.gradle.kts`
- [ ] Đã thêm `implementation(platform("com.google.firebase:firebase-bom:32.7.0"))` vào dependencies
- [ ] Đã thêm Google Services plugin vào `android/build.gradle.kts`
- [ ] Đã tạo Android OAuth Client ID trong Google Cloud Console
- [ ] Đã flutter clean và test lại


