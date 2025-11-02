# Cấu hình nhận diện giọng nói tiếng Việt

## Thay đổi đã thực hiện

Đã cấu hình thư viện `speech_to_text` để hỗ trợ nhận diện tiếng Việt trong ứng dụng. Các thay đổi chính:

### 1. Cấu hình locale
- Sử dụng locale `vi_VN` cho tiếng Việt
- Tự động kiểm tra xem thiết bị có hỗ trợ tiếng Việt hay không
- Nếu không hỗ trợ, sẽ sử dụng locale mặc định của hệ thống

### 2. Files đã được cập nhật:
- `lib/add_data_screen.dart` - Màn hình thêm dữ liệu
- `lib/care_log_screen.dart` - Màn hình nhật ký chăm sóc
- `lib/food_inventory_screen.dart` - Màn hình kho thức ăn

### 3. Quyền đã được cấu hình:
File `android/app/src/main/AndroidManifest.xml` đã có permission:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

## Cách sử dụng

1. Khi người dùng nhấn nút microphone (mic icon):
   - Ứng dụng sẽ tự động kiểm tra và sử dụng tiếng Việt nếu thiết bị hỗ trợ
   - Ghi âm trong 30 giây hoặc tạm dừng sau 3 giây im lặng
   - Văn bản được nhận diện sẽ hiển thị trực tiếp vào ô nhập liệu

2. Người dùng cần cấp quyền:
   - Quyền micro khi lần đầu sử dụng tính năng
   - Quyền có thể được quản lý trong Settings của điện thoại

## Lưu ý

- Cần kết nối Internet để nhận diện tiếng Việt (Google Speech Recognition)
- Độ chính xác phụ thuộc vào:
  - Chất lượng micro
  - Môi trường âm thanh (tránh tiếng ồn)
  - Phát âm rõ ràng
  - Tốc độ nói vừa phải

## Demo

Tính năng hoạt động tại các màn hình:
- **Thêm dữ liệu**: Nhập cân nặng, loại chăm sóc, tên vaccine bằng giọng nói
- **Nhật ký chăm sóc**: Thêm ghi chú bằng giọng nói
- **Kho thức ăn**: Nhập số lượng thức ăn bằng giọng nói










