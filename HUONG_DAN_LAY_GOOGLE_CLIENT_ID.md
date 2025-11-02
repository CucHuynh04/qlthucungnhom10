# Hướng Dẫn Lấy Google OAuth 2.0 Client ID

## ⚠️ QUAN TRỌNG:
**Client ID bạn cần KHÔNG phải là `appId` trong Firebase config!**

- `appId: "1:905772912335:web:79c4ed4f238bffcd4d31ba"` ← Đây KHÔNG phải Client ID
- Google OAuth Client ID có định dạng: `XXXXX-YYYYY.apps.googleusercontent.com`

## Cách 1: Lấy từ Firebase Console (Dễ nhất)

### Bước 1: Vào Authentication Settings
1. Firebase Console → Chọn project `flutter-firebase-5592b`
2. Vào **Authentication** (trong menu bên trái)
3. Chọn tab **Settings**
4. Scroll xuống phần **Authorized domains**

### Bước 2: Lấy Client ID từ Google Cloud Console
1. Trong phần **Settings** của Authentication, tìm link **"Advanced settings"** hoặc **"OAuth consent screen"**
2. Hoặc truy cập trực tiếp: [Google Cloud Console](https://console.cloud.google.com/)
3. Chọn project `flutter-firebase-5592b`
4. Vào **APIs & Services** → **Credentials**
5. Tìm trong danh sách **OAuth 2.0 Client IDs**
6. Tìm client có tên như **"Web client (auto created by Google Service)"** hoặc có **Type: Web application**
7. Click vào để xem chi tiết
8. Copy **Client ID** (có dạng: `905772912335-xxxxxxxxxxxxx.apps.googleusercontent.com`)

## Cách 2: Tạo mới OAuth Client ID (Nếu chưa có)

### Nếu bạn không thấy OAuth Client ID:

1. Vào [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project `flutter-firebase-5592b`
3. Vào **APIs & Services** → **Credentials**
4. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
5. Chọn **Application type**: **Web application**
6. Đặt tên: `Web client` hoặc tên bạn muốn
7. Thêm **Authorized JavaScript origins**:
   - `http://localhost`
   - `http://localhost:8080`
   - `http://localhost:5000`
   - (Thêm các port bạn dùng)
8. Thêm **Authorized redirect URIs**:
   - `http://localhost`
   - `http://localhost:8080`
9. Click **CREATE**
10. Copy **Client ID** hiển thị (có dạng: `XXXXX-YYYYY.apps.googleusercontent.com`)

## Cách 3: Tự động tạo khi bật Google Sign-In

1. Firebase Console → **Authentication** → **Sign-in method**
2. Click vào **Google** provider
3. Bật toggle **Enable**
4. Chọn **Support email**
5. Click **Save**
6. Firebase sẽ tự động tạo OAuth Client ID
7. Sau đó lấy Client ID bằng **Cách 1** ở trên

## Sau khi có Client ID:

1. Mở file `web/index.html`
2. Tìm dòng:
   ```html
   <meta name="google-signin-client_id" content="YOUR_CLIENT_ID_HERE.apps.googleusercontent.com">
   ```
3. Thay `YOUR_CLIENT_ID_HERE.apps.googleusercontent.com` bằng Client ID thực tế của bạn
4. Ví dụ:
   ```html
   <meta name="google-signin-client_id" content="905772912335-abc123xyz789.apps.googleusercontent.com">
   ```
5. **Restart** ứng dụng web

## Kiểm tra:

- Client ID đúng sẽ có định dạng: `[số]-[chuỗi].apps.googleusercontent.com`
- Ví dụ: `905772912335-abc123def456.apps.googleusercontent.com`
- Client ID thường dài khoảng 40-60 ký tự


