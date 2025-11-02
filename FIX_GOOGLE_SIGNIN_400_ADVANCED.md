# Sửa Lỗi 400 Google Sign-In - Hướng Dẫn Nâng Cao

## Đã thực hiện:
✅ Client ID đã được thêm vào HTML meta tag
✅ Client ID đã được thêm vào GoogleSignIn constructor trong code
✅ Scopes đã được thêm: ['email', 'profile']

## Kiểm tra thêm:

### 1. Kiểm tra Google Sign-In API đã được bật
1. Vào [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project: **flutter-firebase-5592b**
3. Vào: **APIs & Services** → **Library**
4. Tìm và bật:
   - **Google+ API** (nếu còn)
   - **Identity Toolkit API**
   - **Google Sign-In JavaScript library** (đã có sẵn)

### 2. Kiểm tra lại Authorized domains trong Firebase
1. Firebase Console → **Authentication** → **Settings**
2. Scroll xuống **Authorized domains**
3. Đảm bảo có:
   - `localhost`
   - `flutter-firebase-5592b.firebaseapp.com`
   - Domain khác mà bạn đang dùng

### 3. Kiểm tra OAuth consent screen
1. Google Cloud Console → **APIs & Services** → **OAuth consent screen**
2. Đảm bảo:
   - **User Type**: Internal hoặc External (tùy nhu cầu)
   - **App name**: Đã có tên
   - **Support email**: Đã chọn email
   - **Authorized domains**: Đã thêm `localhost` nếu cần

### 4. Xóa cache và restart
1. Xóa cache browser:
   - Chrome: Ctrl + Shift + Delete → Clear cached images and files
   - Hoặc dùng Incognito mode để test
2. **Restart** Flutter web app hoàn toàn:
   ```bash
   # Dừng app (Ctrl + C)
   # Chạy lại
   flutter run -d chrome
   ```

### 5. Kiểm tra console log
Mở Developer Tools (F12) và xem Console tab khi click đăng nhập Google, xem có lỗi gì không.

### 6. Kiểm tra redirect URI
Trong Google Cloud Console → Credentials → OAuth Client ID:
- **Authorized redirect URIs** phải có:
  ```
  http://localhost
  http://localhost:8080
  http://localhost:5000
  http://127.0.0.1
  ```
  Và đặc biệt:
  ```
  http://localhost:8080/__/auth/handler
  http://localhost/__/auth/handler
  ```

### 7. Thử cách khác: Dùng Firebase Auth trực tiếp
Nếu vẫn lỗi, có thể thử dùng Firebase Auth UI thay vì GoogleSignIn package. Nhưng cách hiện tại với GoogleSignIn package là đúng.

### 8. Kiểm tra phiên bản package
Đảm bảo `google_sign_in` package đã được cập nhật:
```yaml
google_sign_in: ^6.2.1
```

## Debug:
Thêm log để xem lỗi chi tiết:
```dart
try {
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  print('Google user: $googleUser');
  // ...
} catch (e, stackTrace) {
  print('Lỗi chi tiết: $e');
  print('Stack trace: $stackTrace');
}
```


