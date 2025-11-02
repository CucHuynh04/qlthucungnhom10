# Sửa Lỗi 400 Google Sign-In

## Lỗi: "400. That's an error. The server cannot process the request because it is malformed."

### Nguyên nhân:
- **Authorized JavaScript origins** chưa được cấu hình trong Google Cloud Console
- **Authorized redirect URIs** chưa được cấu hình

### Cách sửa:

#### Bước 1: Vào Google Cloud Console
1. Truy cập: https://console.cloud.google.com/
2. Chọn project: **flutter-firebase-5592b**
3. Vào: **APIs & Services** → **Credentials**

#### Bước 2: Tìm và chỉnh sửa OAuth 2.0 Client ID
1. Tìm OAuth Client ID có Client ID: `905772912335-slflqvo23plqorc6qti04fgg2ifct2le.apps.googleusercontent.com`
2. Click vào để chỉnh sửa

#### Bước 3: Thêm Authorized JavaScript origins
Trong phần **Authorized JavaScript origins**, thêm các URL sau:
```
http://localhost
http://localhost:8080
http://localhost:3000
http://localhost:5000
http://127.0.0.1
http://127.0.0.1:8080
```
*(Thêm các port mà bạn đang chạy ứng dụng)*

#### Bước 4: Thêm Authorized redirect URIs
Trong phần **Authorized redirect URIs**, thêm:
```
http://localhost
http://localhost:8080
http://localhost:3000
http://localhost:5000
http://127.0.0.1
http://127.0.0.1:8080
http://localhost:8080/__/auth/handler
http://localhost/__/auth/handler
```

#### Bước 5: Lưu và kiểm tra
1. Click **SAVE**
2. Đợi vài giây để cập nhật
3. **Restart** ứng dụng Flutter web
4. Thử đăng nhập Google lại

### Nếu vẫn lỗi:

#### Kiểm tra Authorized domains trong Firebase:
1. Firebase Console → **Authentication** → **Settings**
2. Scroll xuống phần **Authorized domains**
3. Đảm bảo có:
   - `localhost`
   - `flutter-firebase-5592b.firebaseapp.com`

#### Kiểm tra Google Sign-In đã bật:
1. Firebase Console → **Authentication** → **Sign-in method**
2. Click vào **Google**
3. Đảm bảo đã **Enable**
4. Có **Support email** được chọn
5. Click **Save**

### Lưu ý:
- Sau khi sửa cấu hình, cần **restart** ứng dụng
- Đảm bảo URL trong browser khớp với Authorized origins đã thêm
- Nếu deploy lên hosting, cần thêm domain thật vào Authorized origins


