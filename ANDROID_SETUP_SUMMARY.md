# Tóm Tắt Cấu Hình Android - Google Sign-In

## ✅ ĐÃ HOÀN THÀNH:

1. ✅ SHA-1 fingerprint đã lấy: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
2. ✅ Đã thêm Google Services plugin vào `android/app/build.gradle.kts`
3. ✅ Đã thêm Google Services plugin vào `android/settings.gradle.kts`
4. ✅ Đã thêm Firebase BOM vào dependencies
5. ✅ Code đã có Client ID: `905772912335-slflqvo23plqorc6qti04fgg2ifct2le.apps.googleusercontent.com`

## 🔧 BẠN CẦN LÀM THÊM:

### BƯỚC 1: Thêm SHA-1 vào Firebase (BẮT BUỘC!)

1. Mở link: https://console.firebase.google.com/project/flutter-firebase-5592b/settings/general
2. Scroll xuống phần **Your apps**
3. Tìm và click Android app (🤖)
4. Trong phần **SHA certificate fingerprints**, click **Add fingerprint**
5. Paste: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
6. Click **Save**

### BƯỚC 2: Download google-services.json (BẮT BUỘC!)

1. Trong cùng trang Firebase
2. Click nút **Download google-services.json**
3. Copy file vào: `android/app/google-services.json`

### BƯỚC 3: Tạo Android OAuth Client ID

1. Mở link: https://console.cloud.google.com/apis/credentials?project=flutter-firebase-5592b
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Chọn **Application type**: **Android**
4. Package name: `com.example.nhom11_giaodien`
5. SHA-1: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B`
6. Click **CREATE**

### BƯỚC 4: Test

```bash
flutter clean
flutter pub get
flutter run
```

## ⚠️ LƯU Ý QUAN TRỌNG:

- **KHÔNG** thêm SHA-1 vào Firebase → Google Sign-In sẽ lỗi DEVELOPER_ERROR
- **KHÔNG** có google-services.json → Firebase không hoạt động
- **PHẢI** flutter clean sau khi sửa các file Gradle

## Trạng thái hiện tại:

| Bước | Trạng thái | Mô tả |
|------|-----------|-------|
| SHA-1 fingerprint | ✅ Hoàn thành | Đã lấy: `73:13:2E:61:87:61:6C:55:70:95:DC:EB:9C:01:4A:04:23:EF:98:1B` |
| Thêm SHA-1 vào Firebase | ⏳ Cần làm | Bạn phải làm thủ công qua browser |
| Download google-services.json | ⏳ Cần làm | Bạn phải download và copy file |
| Google Services plugin | ✅ Hoàn thành | Đã thêm vào build.gradle |
| Firebase BOM | ✅ Hoàn thành | Đã thêm vào dependencies |
| Android OAuth Client ID | ⏳ Cần làm | Tạo trong Google Cloud Console |
| Test trên Android | ⏳ Chưa | Cần hoàn thành các bước trên |

## File đã được sửa:

- ✅ `android/app/build.gradle.kts` - Đã thêm Google Services plugin và Firebase BOM
- ✅ `android/settings.gradle.kts` - Đã thêm Google Services plugin

## Xem chi tiết:

- Hướng dẫn đầy đủ: `ANDROID_GOOGLE_SIGN_IN_SETUP.md`
- Hướng dẫn nhanh: `ANDROID_GOOGLE_SIGN_IN_QUICK_FIX.md`


