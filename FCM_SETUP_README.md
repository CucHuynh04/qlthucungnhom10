# Firebase Cloud Messaging Setup Guide

## Đã hoàn thành trong code:

1. ✅ Đã thêm `firebase_messaging` dependency
2. ✅ Đã tích hợp FCM vào `NotificationService`
3. ✅ Đã đăng ký background message handler
4. ✅ Đã request permission và lấy FCM token

## Cần cấu hình thêm:

### 1. Android
Thêm vào `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<application>
    <service
        android:name="com.google.firebase.messaging.FirebaseMessagingService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
</application>
```

### 2. iOS
Thêm vào `ios/Runner/Info.plist`:
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

Request notification permission trong Xcode.

### 3. Google Services
- Đảm bảo đã thêm `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
- Đã bật Cloud Messaging API trong Firebase Console

## Test FCM

1. Chạy app và đăng ký để nhận FCM token
2. Vào Firebase Console > Cloud Messaging
3. Tạo test notification và gửi theo token hoặc topic














