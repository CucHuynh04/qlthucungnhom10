# Sửa lỗi: Tìm kiếm và nhạc nền

## ✅ Đã sửa

### 1. Lỗi tiêu đề "search_pets" hiển thị raw string
**Vấn đề:** Tiêu đề hiển thị "search_pets" thay vì "Tìm kiếm"
**Giải pháp:** 
- Đổi từ `'search_pets'.tr()` sang `'search'.tr()`
- `'search'` đã có trong file localization

### 2. Nhạc không tự động bật khi mở app
**Vấn đề:** Nhạc không tự phát khi mở app, phải vào Settings tắt/mở mới chạy
**Giải pháp:** 
- Thêm cờ `_hasAutoPlayed` để track lần đầu auto play
- Thêm hàm `_autoPlay()` trong `BackgroundMusicService`
- Auto play sau 1 giây khi service initialized
- Đảm bảo nhạc chỉ auto play 1 lần

## 📝 Chi tiết thay đổi

### File: `lib/filter_search_screen.dart`
```dart
title: Text('search'.tr(), style: const TextStyle(color: Colors.white)),
```

### File: `lib/background_music_service.dart`
**Thêm:**
- `bool _hasAutoPlayed = false;` - Đánh dấu đã auto play
- Hàm `_autoPlay()` - Tự động phát nhạc lần đầu
- Trong `_initPlayer()`: Auto play sau 1 giây nếu enabled

**Logic mới:**
```dart
void _initPlayer() async {
  // ... setup code ...
  
  // Auto play nếu enabled
  if (_isEnabled && !_hasAutoPlayed) {
    await Future.delayed(const Duration(seconds: 1));
    await _autoPlay();
  }
}

Future<void> _autoPlay() async {
  if (!_isEnabled || _hasAutoPlayed) return;
  try {
    print('Auto playing music...');
    await _playCurrentTrack();
    _hasAutoPlayed = true;
  } catch (e) {
    print('Error auto playing music: $e');
  }
}
```

### File: `lib/main.dart` và `lib/home_page.dart`
**Thêm delay:**
```dart
Future.delayed(const Duration(milliseconds: 500), () {
  final musicService = context.read<BackgroundMusicService>();
  if (musicService.isEnabled && !musicService.isPlaying) {
    musicService.play();
  }
});
```

## 🎯 Kết quả

1. ✅ Tiêu đề "Tìm kiếm" hiển thị đúng thay vì "search_pets"
2. ✅ Nhạc tự động bật sau 1 giây khi mở app
3. ✅ Không cần vào Settings để bật nhạc

## 🔄 Cách hoạt động

1. **App khởi động** → `main.dart` chờ 500ms → check và bật nhạc
2. **Vào HomePage** → chờ 500ms → check và bật nhạc
3. **BackgroundMusicService** → Auto play sau 1 giây nếu enabled
4. **Chỉ auto play 1 lần** → `_hasAutoPlayed = true` ngăn phát lại






