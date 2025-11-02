# Chức Năng Kho Thức Ăn - Hướng dẫn sử dụng

## 🍽️ Tổng quan

App bây giờ có chức năng quản lý kho thức ăn theo số lượng cụ thể (theo kg). Mỗi bữa ăn sẽ tự động trừ đi số lượng thức ăn trong kho.

## ✨ Tính năng mới

### 1. Kho Thức Ăn (Food Inventory)
- 📍 Vị trí: Drawer → **Kho Thức Ăn**
- 🎯 Chức năng:
  - Quản lý inventory thức ăn theo kg
  - Theo dõi số lượng còn lại / tổng
  - Progress bar trực quan
  - Cảnh báo khi thức ăn sắp hết (< 20%)
  - Tính số bữa ăn còn lại

### 2. Model FoodInventory
- `totalWeight`: Tổng số kg ban đầu
- `remainingWeight`: Số kg còn lại (tự động giảm khi cho ăn)
- `remainingPercentage`: Phần trăm còn lại
- `remainingMeals`: Số bữa ăn còn lại (mỗi bữa 0.05kg)

### 3. Tự động trừ khi cho ăn
- Khi cho thú cưng ăn, số kg sẽ tự động trừ khỏi kho
- Lịch sử ăn uống được ghi lại trong `foodHistory`
- Đồng bộ tự động lên Firebase

## 🎮 Cách sử dụng

### Thêm thức ăn vào kho

1. Vào **Drawer → Kho Thức Ăn**
2. Chọn thú cưng
3. Nhấn nút **"+"** (Floating Action Button)
4. Nhập thông tin:
   - **Tên thức ăn**: VD: "Thức ăn khô hạt nhỏ"
   - **Loại**: VD: "Dry Food", "Wet Food", "Treat"
   - **Tổng trọng lượng (kg)**: VD: `5.0`
   - **Chi phí**: VD: `250000`
5. Nhấn **"Thêm"**

### Cho thú cưng ăn

1. Xem danh sách thức ăn trong kho
2. Chọn loại thức ăn muốn cho ăn
3. Nhấn icon **🥘 Restaurant** (bên phải mỗi item)
4. Nhập số kg muốn cho ăn (VD: `0.05`)
5. Nhấn **"Cho ăn"**
6. ✅ Số kg tự động trừ khỏi kho
7. ✅ Ghi lại vào lịch sử ăn uống

## 🎨 Giao diện

### Màu sắc hiển thị
- 🟢 **Xanh lá**: > 50% còn lại
- 🟠 **Cam**: 20-50% còn lại  
- 🔴 **Đỏ**: < 20% còn lại (sắp hết)

### Progress Bar
```
[████████████░░░░░] 75% còn lại
```

### Thông tin hiển thị
- Tên thức ăn
- Loại thức ăn
- Số kg còn lại / Tổng số kg
- Số bữa ăn còn lại
- Màu cảnh báo

## 📊 Dữ liệu

### Lưu trữ
- **Local**: Trong `Pet.foodInventory[]`
- **Firebase**: Đồng bộ tự động lên Realtime Database

### Cấu trúc dữ liệu
```dart
{
  'id': 'f1',
  'name': 'Thức ăn khô',
  'type': 'Dry Food',
  'totalWeight': 5.0,
  'remainingWeight': 3.2,
  'purchaseDate': '2024-01-01',
  'cost': 250000,
  'notes': 'Thức ăn cho mèo'
}
```

## 🔧 Technical Details

### PetService Methods
```dart
// Thêm thức ăn vào kho
addFoodToInventory(petId, food)

// Cho thú cưng ăn (tự động trừ)
feedPet(petId, foodId, amount)

// Lấy danh sách thức ăn
getFoodInventory(petId)
```

### Tính năng tương tác
- 🔊 **Âm thanh click** khi nhấn nút
- 🎨 **Animation** fade-in, slide
- 🎤 **Microphone** hỗ trợ nhập giọng nói

## 💡 Tips

### Số bữa ăn hợp lý
- Mỗi bữa ăn: **0.05kg** (50g)
- 1kg = **20 bữa**
- 5kg = **100 bữa**

### Khi nào cần mua thêm
- Khi còn < 0.5kg (10 bữa)
- Khi còn < 20% tổng

### Quản lý tốt
- Thường xuyên kiểm tra kho
- Ghi chú loại thức ăn phù hợp với thú cưng
- Theo dõi chi phí

## 🚀 Kết quả

App bây giờ có hệ thống quản lý thức ăn hoàn chỉnh:
- ✅ Theo dõi số lượng cụ thể (kg)
- ✅ Tự động trừ khi cho ăn
- ✅ Cảnh báo khi sắp hết
- ✅ Tính số bữa còn lại
- ✅ Đồng bộ Firebase
- ✅ Animation đẹp mắt

Chúc bạn quản lý kho thức ăn tốt! 🐾



