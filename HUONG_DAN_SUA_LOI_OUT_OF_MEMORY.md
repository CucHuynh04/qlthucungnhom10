# Hướng dẫn sửa lỗi "Out of memory" khi build Flutter

## Nguyên nhân
Lỗi "Out of memory" xảy ra khi:
- RAM không đủ để compile Dart code
- Virtual memory (paging file) trên Windows quá nhỏ
- Gradle hoặc Dart compiler sử dụng quá nhiều bộ nhớ

## Giải pháp

### 1. Tăng Virtual Memory (Paging File) trên Windows

1. **Mở System Properties:**
   - Nhấn `Win + R`
   - Gõ `sysdm.cpl` và nhấn Enter
   - Hoặc: Settings > System > About > Advanced system settings

2. **Vào Performance Settings:**
   - Tab **Advanced**
   - Click **Settings** trong phần **Performance**

3. **Chỉnh Virtual Memory:**
   - Tab **Advanced**
   - Click **Change** trong phần **Virtual memory**
   - Bỏ chọn **Automatically manage paging file size for all drives**
   - Chọn ổ C: (hoặc ổ có nhiều dung lượng)
   - Chọn **Custom size**
   - Đặt:
     - **Initial size (MB)**: `4096` (4GB)
     - **Maximum size (MB)**: `8192` (8GB) hoặc `16384` (16GB) nếu có đủ dung lượng
   - Click **Set**
   - Click **OK**

4. **Restart máy tính** để áp dụng thay đổi

### 2. Tắt các ứng dụng không cần thiết
- Đóng các ứng dụng đang chạy (browser, IDE khác, v.v.)
- Giải phóng RAM trước khi build

### 3. Build với cấu hình tối thiểu

Đã cập nhật `android/gradle.properties` với:
- Giảm Gradle memory: `-Xmx2G` (từ 4G)
- Giảm Metaspace: `1G` (từ 2G)
- Tắt parallel build
- Giữ daemon để tăng tốc

### 4. Thử build lại

Sau khi tăng virtual memory và restart máy:

```bash
flutter clean
flutter pub get
flutter run
```

### 5. Nếu vẫn lỗi, thử build release mode

Release mode thường nhẹ hơn debug:

```bash
flutter build apk --release
```

Hoặc build và cài thủ công:
```bash
flutter build apk
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 6. Giảm số lượng file compile cùng lúc

Thêm vào `pubspec.yaml` (nếu có thể):
```yaml
flutter:
  # Giảm số lượng file compile
  uses-material-design: true
```

### 7. Kiểm tra RAM và Disk Space

- **RAM tối thiểu**: 8GB (khuyến nghị 16GB)
- **Disk Space**: Ít nhất 10GB trống cho build process
- **Virtual Memory**: Ít nhất 8GB

## Lưu ý

- Sau khi tăng virtual memory, **phải restart máy** mới có hiệu lực
- Build lần đầu thường chậm và tốn nhiều bộ nhớ hơn
- Nếu máy chỉ có 4GB RAM, nên nâng cấp RAM hoặc build trên máy khác mạnh hơn


