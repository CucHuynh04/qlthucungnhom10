// lib/firebase_sync_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

/// Service để đồng bộ dữ liệu với Firebase Realtime Database
class FirebaseSyncService {
  static final FirebaseSyncService _instance = FirebaseSyncService._internal();
  factory FirebaseSyncService() => _instance;
  FirebaseSyncService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy user ID hiện tại
  String? get userId => _auth.currentUser?.uid;

  /// Kiểm tra user đã đăng nhập chưa
  bool get isLoggedIn => _auth.currentUser != null;

  /// Lưu dữ liệu thú cưng lên Firebase
  Future<void> syncPetToFirebase(Map<String, dynamic> petData) async {
    if (!isLoggedIn || userId == null) return;

    try {
      await _database
          .child('users')
          .child(userId!)
          .child('pets')
          .child(petData['id'])
          .set(petData);
    } catch (e) {
      print('Error syncing pet to Firebase: $e');
      rethrow;
    }
  }

  /// Xóa thú cưng khỏi Firebase
  Future<void> deletePetFromFirebase(String petId) async {
    if (!isLoggedIn || userId == null) return;

    try {
      await _database
          .child('users')
          .child(userId!)
          .child('pets')
          .child(petId)
          .remove();
    } catch (e) {
      print('Error deleting pet from Firebase: $e');
      rethrow;
    }
  }

  /// Đồng bộ toàn bộ danh sách thú cưng
  Future<void> syncAllPetsToFirebase(List<Map<String, dynamic>> pets) async {
    if (!isLoggedIn || userId == null) return;

    try {
      final petsMap = <String, Map<String, dynamic>>{};
      for (final pet in pets) {
        petsMap[pet['id']] = pet;
      }

      await _database
          .child('users')
          .child(userId!)
          .child('pets')
          .set(petsMap);
    } catch (e) {
      print('Error syncing all pets to Firebase: $e');
      rethrow;
    }
  }

  /// Tải dữ liệu thú cưng từ Firebase
  Future<List<Map<String, dynamic>>> loadPetsFromFirebase() async {
    if (!isLoggedIn || userId == null) return [];

    try {
      final snapshot = await _database
          .child('users')
          .child(userId!)
          .child('pets')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          final pet = entry.value as Map<dynamic, dynamic>;
          pet['id'] = entry.key;
          return Map<String, dynamic>.from(pet);
        }).toList();
      }

      return [];
    } catch (e) {
      print('Error loading pets from Firebase: $e');
      return [];
    }
  }

  /// Lưu lịch hẹn lên Firebase
  Future<void> syncScheduleToFirebase(
      String petId, Map<String, dynamic> scheduleData) async {
    if (!isLoggedIn || userId == null) return;

    try {
      await _database
          .child('users')
          .child(userId!)
          .child('schedules')
          .child(petId)
          .child(scheduleData['id'])
          .set(scheduleData);
    } catch (e) {
      print('Error syncing schedule to Firebase: $e');
      rethrow;
    }
  }

  /// Xóa lịch hẹn khỏi Firebase
  Future<void> deleteScheduleFromFirebase(String petId, String scheduleId) async {
    if (!isLoggedIn || userId == null) return;

    try {
      await _database
          .child('users')
          .child(userId!)
          .child('schedules')
          .child(petId)
          .child(scheduleId)
          .remove();
    } catch (e) {
      print('Error deleting schedule from Firebase: $e');
      rethrow;
    }
  }

  /// Tải toàn bộ dữ liệu người dùng từ Firebase
  Future<Map<String, dynamic>?> loadAllUserData() async {
    if (!isLoggedIn || userId == null) return null;

    try {
      final snapshot = await _database.child('users').child(userId!).get();

      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }

      return null;
    } catch (e) {
      print('Error loading user data from Firebase: $e');
      return null;
    }
  }

  /// Lắng nghe thay đổi dữ liệu từ Firebase (real-time)
  Stream<DatabaseEvent> getPetsStream() {
    if (!isLoggedIn || userId == null) {
      return const Stream.empty();
    }

    return _database
        .child('users')
        .child(userId!)
        .child('pets')
        .onValue;
  }

  /// Lắng nghe thay đổi lịch hẹn từ Firebase
  Stream<DatabaseEvent> getSchedulesStream(String petId) {
    if (!isLoggedIn || userId == null) {
      return const Stream.empty();
    }

    return _database
        .child('users')
        .child(userId!)
        .child('schedules')
        .child(petId)
        .onValue;
  }

  /// Đăng ký thay đổi dữ liệu thú cưng
  void listenToPetsChanges(Function(List<Map<String, dynamic>>) callback) {
    if (!isLoggedIn || userId == null) return;

    _database
        .child('users')
        .child(userId!)
        .child('pets')
        .onValue
        .listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final pets = data.entries.map((entry) {
          final pet = entry.value as Map<dynamic, dynamic>;
          pet['id'] = entry.key;
          return Map<String, dynamic>.from(pet);
        }).toList();
        callback(pets);
      }
    });
  }

  /// Lưu thông tin profile người dùng
  Future<void> saveUserProfile(Map<String, dynamic> profileData) async {
    if (!isLoggedIn || userId == null) return;

    try {
      await _database
          .child('users')
          .child(userId!)
          .child('profile')
          .set(profileData);
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  /// Tải thông tin profile người dùng
  Future<Map<String, dynamic>?> loadUserProfile() async {
    if (!isLoggedIn || userId == null) return null;

    try {
      final snapshot = await _database
          .child('users')
          .child(userId!)
          .child('profile')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }

      return null;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  /// Clear tất cả dữ liệu user (dùng khi logout)
  Future<void> clearUserData() async {
    if (!isLoggedIn || userId == null) return;

    try {
      await _database.child('users').child(userId!).remove();
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }
}








