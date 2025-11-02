# Hướng Dẫn Cấu Hình Google Sign-In cho Web

## Lỗi gặp phải:
```
ClientID not set. Either set it on a <meta name="google-signin-client_id" content="CLIENT_ID" /> tag, or pass clientId when initializing GoogleSignIn
```

## Cách sửa lỗi:

### Bước 1: Lấy Google Client ID từ Firebase Console

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn: `flutter-firebase-5592b`
3. Vào **Project Settings** (biểu tượng bánh răng ở góc trên bên trái)
4. Scroll xuống phần **Your apps**
5. Chọn **Web app** (biểu tượng `</>`)
6. Trong phần **Firebase SDK snippet**, chọn tab **Configuration**
7. Tìm **OAuth 2.0 Client IDs** - đây là Google Client ID bạn cần
   - Hoặc vào **Authentication** > **Settings** > **Authorized domains** để xem Client ID

### Bước 2: Thêm Client ID vào file HTML

Mở file `web/index.html` và thay thế dòng:
```html
<meta name="google-signin-client_id" content="YOUR_CLIENT_ID_HERE.apps.googleusercontent.com">
```

Bằng Client ID thực tế của bạn, ví dụ:
```html
<meta name="google-signin-client_id" content="905772912335-xxxxxxxxxxxxx.apps.googleusercontent.com">
```

### Bước 3: Đảm bảo OAuth đã được bật trong Firebase

1. Vào Firebase Console > **Authentication**
2. Chọn tab **Sign-in method**
3. Bật **Google** sign-in provider
4. Nhập **Support email**
5. Lưu

### Lưu ý:
- Client ID thường có dạng: `XXXXX-YYYYY.apps.googleusercontent.com`
- Sau khi thêm Client ID, cần **restart** ứng dụng web
- Nếu vẫn lỗi, kiểm tra lại Client ID và đảm bảo domain đã được authorize trong Firebase


