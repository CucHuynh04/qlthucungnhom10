// lib/pet_service.dart

import 'package:flutter/material.dart';
import 'firebase_sync_service.dart';

// 1. Pet Model (Mở rộng với các trường mới)
class Pet {
  final String id;
  String name;
  String species;
  String breed;
  String gender;
  String birthDate; // Lưu dưới dạng chuỗi 'DD/MM/YYYY'
  String? imageUrl; // URL ảnh
  double? weight; // Cân nặng (kg)
  List<WeightRecord> weightHistory; // Lịch sử cân nặng
  List<CareRecord> careHistory; // Lịch sử chăm sóc
  List<VaccinationRecord> vaccinationHistory; // Lịch sử tiêm chủng
  List<AccessoryRecord> accessoryHistory; // Lịch sử phụ kiện
  List<FoodRecord> foodHistory; // Lịch sử thức ăn
  List<FoodInventory> foodInventory; // Kho thức ăn hiện có
  List<MediaItem> mediaItems; // Danh sách ảnh/video trong gallery

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.gender,
    required this.birthDate,
    this.imageUrl,
    this.weight,
    this.weightHistory = const [],
    this.careHistory = const [],
    this.vaccinationHistory = const [],
    this.accessoryHistory = const [],
    this.foodHistory = const [],
    this.foodInventory = const [],
    this.mediaItems = const [],
  });
}

// Model cho inventory thức ăn
class FoodInventory {
  final String id;
  final String name;
  final String type;
  final double totalWeight; // Tổng số kg
  double remainingWeight; // Số kg còn lại
  final DateTime purchaseDate;
  final double? cost;
  final String? notes;

  FoodInventory({
    required this.id,
    required this.name,
    required this.type,
    required this.totalWeight,
    required this.remainingWeight,
    required this.purchaseDate,
    this.cost,
    this.notes,
  });

  // Tính phần trăm còn lại
  double get remainingPercentage => (remainingWeight / totalWeight) * 100;
  
  // Tính số bữa ăn còn lại (giả sử mỗi bữa ăn 0.05kg)
  int get remainingMeals => (remainingWeight / 0.05).floor();
}

// Model cho lịch sử cân nặng
class WeightRecord {
  final String id;
  final double weight;
  final DateTime date;
  final String? notes;

  WeightRecord({
    required this.id,
    required this.weight,
    required this.date,
    this.notes,
  });
}

// Model cho lịch sử chăm sóc
class CareRecord {
  final String id;
  final String type; // Loại chăm sóc (ăn uống, đi dạo, tắm, etc.)
  final DateTime date;
  final double? cost; // Chi phí
  final String? notes;

  CareRecord({
    required this.id,
    required this.type,
    required this.date,
    this.cost,
    this.notes,
  });
}

// Model cho lịch sử tiêm chủng
class VaccinationRecord {
  final String id;
  final String vaccineName;
  final DateTime date;
  final DateTime? nextDueDate;
  final String? notes;

  VaccinationRecord({
    required this.id,
    required this.vaccineName,
    required this.date,
    this.nextDueDate,
    this.notes,
  });
}

// Model cho phụ kiện
class AccessoryRecord {
  final String id;
  final String name;
  final String type; // Loại phụ kiện (collar, leash, toy, etc.)
  final DateTime date;
  final double? cost;
  final String? notes;

  AccessoryRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    this.cost,
    this.notes,
  });
}

// Model cho thức ăn
class FoodRecord {
  final String id;
  final String name;
  final String type; // Loại thức ăn (dry food, wet food, treat, etc.)
  final DateTime date;
  final double? cost;
  final String? notes;

  FoodRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    this.cost,
    this.notes,
  });
}

// Model cho lịch hẹn
class ScheduleRecord {
  final String id;
  final String petId;
  final String title;
  final String type; // 'care', 'vaccination', 'play'
  final DateTime date;
  final String? time;
  final String? notes;

  ScheduleRecord({
    required this.id,
    required this.petId,
    required this.title,
    required this.type,
    required this.date,
    this.time,
    this.notes,
  });
}

// Model cho media (ảnh/video) trong gallery
class MediaItem {
  final String id;
  final String petId;
  final String type; // 'photo' hoặc 'video'
  final String path; // Đường dẫn file
  final DateTime date;
  final String title;

  MediaItem({
    required this.id,
    required this.petId,
    required this.type,
    required this.path,
    required this.date,
    required this.title,
  });
}

// 2. Pet Service (Đã cập nhật các hàm)
class PetService extends ChangeNotifier {
  final FirebaseSyncService _syncService = FirebaseSyncService();
  
  // Danh sách lịch hẹn
  final List<ScheduleRecord> _schedules = [];
  
  // Danh sách thú cưng hiện tại với dữ liệu mẫu đầy đủ
  final List<Pet> _pets = [
    Pet(
      id: '1', 
      name: 'Miu', 
      species: 'Mèo', 
      breed: 'Anh Lông Ngắn', 
      gender: 'Cái', 
      birthDate: '10/10/2023', 
      imageUrl: null,
      weight: 3.5,
      weightHistory: [
        WeightRecord(id: 'w1', weight: 3.2, date: DateTime(2023, 10, 5)),
        WeightRecord(id: 'w2', weight: 4.8, date: DateTime(2023, 11, 10)),
        WeightRecord(id: 'w3', weight: 6.5, date: DateTime(2023, 12, 15)),
        WeightRecord(id: 'w4', weight: 8.2, date: DateTime(2024, 1, 20)),
        WeightRecord(id: 'w5', weight: 9.8, date: DateTime(2024, 2, 25)),
      ],
      careHistory: [
        CareRecord(id: 'c1', type: 'Tắm', date: DateTime(2023, 11, 15), cost: 150000),
        CareRecord(id: 'c2', type: 'Cắt móng', date: DateTime(2023, 12, 10), cost: 80000),
      ],
      vaccinationHistory: [
        VaccinationRecord(id: 'v1', vaccineName: 'Tiêm phòng cơ bản', date: DateTime(2023, 10, 15)),
      ],
      accessoryHistory: [
        AccessoryRecord(id: 'a1', name: 'Collar đỏ', type: 'Collar', date: DateTime(2023, 11, 1), cost: 50000),
        AccessoryRecord(id: 'a2', name: 'Đồ chơi chuột', type: 'Toy', date: DateTime(2023, 12, 1), cost: 30000),
      ],
      foodHistory: [
        FoodRecord(id: 'f1', name: 'Thức ăn khô Royal Canin', type: 'Dry Food', date: DateTime(2023, 11, 1), cost: 200000),
        FoodRecord(id: 'f2', name: 'Pate Whiskas', type: 'Wet Food', date: DateTime(2023, 12, 1), cost: 150000),
      ],
    ),
    Pet(
      id: '2', 
      name: 'Gâu', 
      species: 'Chó', 
      breed: 'Poodle', 
      gender: 'Đực', 
      birthDate: '05/03/2022', 
      imageUrl: null,
      weight: 8.2,
      weightHistory: [
        WeightRecord(id: 'w4', weight: 7.8, date: DateTime(2023, 10, 1)),
        WeightRecord(id: 'w5', weight: 8.0, date: DateTime(2023, 11, 1)),
        WeightRecord(id: 'w6', weight: 8.2, date: DateTime(2023, 12, 1)),
      ],
      careHistory: [
        CareRecord(id: 'c3', type: 'Đi dạo', date: DateTime(2023, 11, 20), cost: 0),
        CareRecord(id: 'c4', type: 'Cắt tỉa lông', date: DateTime(2023, 12, 5), cost: 200000),
      ],
      vaccinationHistory: [
        VaccinationRecord(id: 'v2', vaccineName: 'Tiêm phòng dại', date: DateTime(2023, 9, 1)),
      ],
      accessoryHistory: [
        AccessoryRecord(id: 'a3', name: 'Dây dắt', type: 'Leash', date: DateTime(2023, 10, 1), cost: 80000),
        AccessoryRecord(id: 'a4', name: 'Bát ăn', type: 'Bowl', date: DateTime(2023, 11, 1), cost: 60000),
      ],
      foodHistory: [
        FoodRecord(id: 'f3', name: 'Thức ăn khô Pedigree', type: 'Dry Food', date: DateTime(2023, 10, 1), cost: 250000),
        FoodRecord(id: 'f4', name: 'Xương gặm', type: 'Treat', date: DateTime(2023, 11, 1), cost: 100000),
      ],
    ),
    Pet(
      id: '3', 
      name: 'Vẹt', 
      species: 'Chim', 
      breed: 'Cockatiel', 
      gender: 'Đực', 
      birthDate: '01/01/2025', 
      imageUrl: null,
      weight: 0.1,
      weightHistory: [
        WeightRecord(id: 'w7', weight: 0.08, date: DateTime(2024, 12, 1)),
        WeightRecord(id: 'w8', weight: 0.09, date: DateTime(2024, 12, 15)),
        WeightRecord(id: 'w9', weight: 0.1, date: DateTime(2025, 1, 1)),
      ],
      careHistory: [
        CareRecord(id: 'c5', type: 'Thay thức ăn', date: DateTime(2024, 12, 10), cost: 50000),
      ],
      vaccinationHistory: [],
      accessoryHistory: [
        AccessoryRecord(id: 'a5', name: 'Lồng chim', type: 'Cage', date: DateTime(2024, 12, 1), cost: 300000),
        AccessoryRecord(id: 'a6', name: 'Cầu đậu', type: 'Perch', date: DateTime(2024, 12, 1), cost: 50000),
      ],
      foodHistory: [
        FoodRecord(id: 'f5', name: 'Hạt giống hỗn hợp', type: 'Seed Mix', date: DateTime(2024, 12, 1), cost: 80000),
        FoodRecord(id: 'f6', name: 'Trái cây tươi', type: 'Fresh Fruit', date: DateTime(2024, 12, 10), cost: 30000),
      ],
    ),
  ];

  List<Pet> get pets => _pets;

  // Hàm Lấy thú cưng theo ID (Giữ nguyên)
  Pet? getPetById(String id) {
    if (id.isEmpty) {
      print('getPetById: Empty ID provided');
      return null;
    }
    
    try {
      final pet = _pets.firstWhere((pet) => pet.id == id);
      print('getPetById: Found pet ID=$id, Name=${pet.name}');
      return pet;
    } catch (e) {
      print('getPetById: Pet not found with ID=$id');
      print('Available IDs: ${_pets.map((p) => p.id).toList()}');
      return null; // Trả về null nếu không tìm thấy
    }
  }

  // Hàm Thêm thú cưng mới (Đã thêm imageUrl + Firebase sync)
  void addPet(Pet newPet) async {
    // Tạo ID duy nhất (sử dụng timestamp + random để tránh trùng)
    final newId = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
    
    // Gán ID mới
    final petWithId = Pet(
      id: newId,
      name: newPet.name,
      species: newPet.species,
      breed: newPet.breed,
      gender: newPet.gender,
      birthDate: newPet.birthDate,
      imageUrl: newPet.imageUrl, // LƯU URL ẢNH MỚI
      weight: newPet.weight,
      weightHistory: [],
      careHistory: [],
      vaccinationHistory: [],
      accessoryHistory: [],
      foodHistory: [],
      foodInventory: [],
      mediaItems: [],
    );
    
    print('Adding new pet: ID=$newId, Name=${petWithId.name}');
    print('Current pets count: ${_pets.length}');
    
    _pets.add(petWithId);
    
    print('After adding, pets count: ${_pets.length}');
    print('Verification: Pet with ID $newId exists? ${getPetById(newId) != null}');
    
    notifyListeners();
    
    // Đồng bộ lên Firebase
    if (_syncService.isLoggedIn) {
      try {
        await _syncService.syncPetToFirebase(_petToMap(petWithId));
      } catch (e) {
        print('Error syncing pet to Firebase: $e');
      }
    }
  }

  // Hàm Cập nhật thông tin thú cưng (Đã thêm imageUrl + Firebase sync)
  void updatePet(Pet updatedPet) async {
    final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
    if (index != -1) {
      _pets[index] = updatedPet; // Ghi đè bằng đối tượng cập nhật (bao gồm cả imageUrl)
      notifyListeners();
      
      // Đồng bộ lên Firebase
      if (_syncService.isLoggedIn) {
        try {
          await _syncService.syncPetToFirebase(_petToMap(updatedPet));
        } catch (e) {
          print('Error syncing pet to Firebase: $e');
        }
      }
    }
  }

  // Hàm Xóa thú cưng (Đã thêm Firebase sync)
  void deletePet(String id) async {
    _pets.removeWhere((pet) => pet.id == id);
    notifyListeners();
    
    // Xóa khỏi Firebase
    if (_syncService.isLoggedIn) {
      try {
        await _syncService.deletePetFromFirebase(id);
      } catch (e) {
        print('Error deleting pet from Firebase: $e');
      }
    }
  }

  // === CÁC TÍNH NĂNG NÂNG CAO ===

  // 1. Bộ lọc và tìm kiếm
  List<Pet> filterPets({
    String? species,
    String? breed,
    String? searchQuery,
  }) {
    List<Pet> filteredPets = _pets;

    // Lọc theo loài
    if (species != null && species.isNotEmpty) {
      filteredPets = filteredPets.where((pet) => pet.species == species).toList();
    }

    // Lọc theo giống
    if (breed != null && breed.isNotEmpty) {
      filteredPets = filteredPets.where((pet) => pet.breed == breed).toList();
    }

    // Tìm kiếm theo tên
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredPets = filteredPets.where((pet) => 
        pet.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        pet.species.toLowerCase().contains(searchQuery.toLowerCase()) ||
        pet.breed.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    return filteredPets;
  }

  // Lấy danh sách các loài có sẵn
  List<String> getAvailableSpecies() {
    return _pets.map((pet) => pet.species).toSet().toList();
  }

  // Lấy danh sách các giống có sẵn
  List<String> getAvailableBreeds() {
    return _pets.map((pet) => pet.breed).toSet().toList();
  }

  // 2. Thống kê và biểu đồ
  Map<String, double> getWeightStatistics(String petId) {
    final pet = getPetById(petId);
    if (pet == null || pet.weightHistory.isEmpty) {
      return {'min': 0, 'max': 0, 'avg': 0, 'current': 0};
    }

    final weights = pet.weightHistory.map((w) => w.weight).toList();
    final min = weights.reduce((a, b) => a < b ? a : b);
    final max = weights.reduce((a, b) => a > b ? a : b);
    final avg = weights.reduce((a, b) => a + b) / weights.length;
    final current = pet.weight ?? 0;

    return {
      'min': min,
      'max': max,
      'avg': avg,
      'current': current,
    };
  }

  Map<String, double> getCareCostStatistics(String petId) {
    final pet = getPetById(petId);
    if (pet == null) {
      return {'total': 0, 'avg': 0, 'thisMonth': 0};
    }

    // Tính tổng chi phí từ tất cả các loại
    final allCosts = <double>[];
    
    // Chi phí chăm sóc
    allCosts.addAll(pet.careHistory.where((c) => c.cost != null).map((c) => c.cost!));
    
    // Chi phí tiêm chủng (giả định có chi phí)
    allCosts.addAll(pet.vaccinationHistory.map((v) => 200000.0)); // Chi phí tiêm chủng cố định
    
    // Chi phí phụ kiện
    allCosts.addAll(pet.accessoryHistory.where((a) => a.cost != null).map((a) => a.cost!));
    
    // Chi phí thức ăn
    allCosts.addAll(pet.foodHistory.where((f) => f.cost != null).map((f) => f.cost!));

    if (allCosts.isEmpty) {
      return {'total': 0, 'avg': 0, 'thisMonth': 0};
    }

    final total = allCosts.reduce((a, b) => a + b);
    final avg = total / allCosts.length;

    // Chi phí tháng này
    final now = DateTime.now();
    final thisMonthCosts = <double>[];
    
    // Chăm sóc tháng này
    thisMonthCosts.addAll(pet.careHistory
        .where((c) => c.date.year == now.year && c.date.month == now.month && c.cost != null)
        .map((c) => c.cost!));
    
    // Tiêm chủng tháng này
    thisMonthCosts.addAll(pet.vaccinationHistory
        .where((v) => v.date.year == now.year && v.date.month == now.month)
        .map((v) => 200000.0));
    
    // Phụ kiện tháng này
    thisMonthCosts.addAll(pet.accessoryHistory
        .where((a) => a.date.year == now.year && a.date.month == now.month && a.cost != null)
        .map((a) => a.cost!));
    
    // Thức ăn tháng này
    thisMonthCosts.addAll(pet.foodHistory
        .where((f) => f.date.year == now.year && f.date.month == now.month && f.cost != null)
        .map((f) => f.cost!));

    final thisMonth = thisMonthCosts.isEmpty ? 0.0 : thisMonthCosts.reduce((a, b) => a + b);

    return {
      'total': total,
      'avg': avg,
      'thisMonth': thisMonth,
    };
  }

  // 3. Thêm dữ liệu mới
  void addWeightRecord(String petId, double weight, String? notes, {DateTime? date}) {
    final pet = getPetById(petId);
    if (pet != null) {
      final record = WeightRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        weight: weight,
        date: date ?? DateTime.now(),
        notes: notes,
      );
      pet.weightHistory.add(record);
      pet.weight = weight; // Cập nhật cân nặng hiện tại
      notifyListeners();
    }
  }

  void addCareRecord(String petId, String type, double? cost, String? notes, {DateTime? date}) {
    final pet = getPetById(petId);
    if (pet != null) {
      final record = CareRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        date: date ?? DateTime.now(),
        cost: cost,
        notes: notes,
      );
      pet.careHistory.add(record);
      notifyListeners();
    }
  }

  void addVaccinationRecord(String petId, String vaccineName, DateTime? nextDueDate, String? notes, {DateTime? date}) {
    final pet = getPetById(petId);
    if (pet != null) {
      final record = VaccinationRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vaccineName: vaccineName,
        date: date ?? DateTime.now(),
        nextDueDate: nextDueDate,
        notes: notes,
      );
      pet.vaccinationHistory.add(record);
      notifyListeners();
    }
  }

  void addAccessoryRecord(String petId, String name, String type, double? cost, String? notes, {DateTime? date}) {
    final pet = getPetById(petId);
    if (pet != null) {
      final record = AccessoryRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: type,
        date: date ?? DateTime.now(),
        cost: cost,
        notes: notes,
      );
      pet.accessoryHistory.add(record);
      notifyListeners();
    }
  }

  void addFoodRecord(String petId, String name, String type, double? cost, String? notes, {DateTime? date}) {
    final pet = getPetById(petId);
    if (pet != null) {
      final record = FoodRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: type,
        date: date ?? DateTime.now(),
        cost: cost,
        notes: notes,
      );
      pet.foodHistory.add(record);
      notifyListeners();
    }
  }

  // Thêm media item vào gallery của thú cưng
  Future<void> addMediaItem(String petId, String type, String path, String title, {DateTime? date}) async {
    final pet = getPetById(petId);
    if (pet != null) {
      final mediaItem = MediaItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: petId,
        type: type,
        path: path,
        date: date ?? DateTime.now(),
        title: title,
      );
      pet.mediaItems = [...pet.mediaItems, mediaItem];
      notifyListeners();
      if (_syncService.isLoggedIn) {
        try {
          await _syncService.syncPetToFirebase(_petToMap(pet));
        } catch (e) {
          print('Error syncing pet to Firebase: $e');
        }
      }
    }
  }

  // Lấy danh sách media của một thú cưng
  List<MediaItem> getMediaItems(String petId) {
    final pet = getPetById(petId);
    return pet?.mediaItems ?? [];
  }

  // Xóa media item
  void deleteMediaItem(String petId, String mediaId) async {
    final pet = getPetById(petId);
    if (pet != null) {
      pet.mediaItems = pet.mediaItems.where((m) => m.id != mediaId).toList();
      notifyListeners();
      if (_syncService.isLoggedIn) {
        try {
          await _syncService.syncPetToFirebase(_petToMap(pet));
        } catch (e) {
          print('Error syncing pet to Firebase: $e');
        }
      }
    }
  }

  // Phương thức quản lý lịch hẹn
  List<ScheduleRecord> get schedules => _schedules;

  void addSchedule(String petId, String title, String type, DateTime date, {String? time, String? notes}) async {
    final schedule = ScheduleRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: petId,
      title: title,
      type: type,
      date: date,
      time: time,
      notes: notes,
    );
    _schedules.add(schedule);
    notifyListeners();
    
    // Đồng bộ lịch hẹn lên Firebase
    if (_syncService.isLoggedIn) {
      try {
        await _syncService.syncScheduleToFirebase(petId, _scheduleToMap(schedule));
      } catch (e) {
        print('Error syncing schedule to Firebase: $e');
      }
    }
  }

  void deleteSchedule(String scheduleId) async {
    final schedule = _schedules.firstWhere((s) => s.id == scheduleId);
    _schedules.removeWhere((schedule) => schedule.id == scheduleId);
    notifyListeners();
    
    // Xóa lịch hẹn khỏi Firebase
    if (_syncService.isLoggedIn) {
      try {
        await _syncService.deleteScheduleFromFirebase(schedule.petId, scheduleId);
      } catch (e) {
        print('Error deleting schedule from Firebase: $e');
      }
    }
  }

  List<ScheduleRecord> getSchedulesForDay(DateTime day) {
    return _schedules.where((schedule) {
      return schedule.date.year == day.year &&
             schedule.date.month == day.month &&
             schedule.date.day == day.day;
    }).toList();
  }

  List<ScheduleRecord> getUpcomingSchedules({int days = 7}) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    
    return _schedules.where((schedule) {
      return schedule.date.isAfter(now) && schedule.date.isBefore(endDate);
    }).toList();
  }

  // === HELPER METHODS FOR FIREBASE SYNC ===
  
  /// Chuyển đổi Pet sang Map để lưu lên Firebase
  Map<String, dynamic> _petToMap(Pet pet) {
    return {
      'id': pet.id,
      'name': pet.name,
      'species': pet.species,
      'breed': pet.breed,
      'gender': pet.gender,
      'birthDate': pet.birthDate,
      'imageUrl': pet.imageUrl,
      'weight': pet.weight,
      'weightHistory': pet.weightHistory.map((w) => {
        'id': w.id,
        'weight': w.weight,
        'date': w.date.toIso8601String(),
        'notes': w.notes,
      }).toList(),
      'careHistory': pet.careHistory.map((c) => {
        'id': c.id,
        'type': c.type,
        'date': c.date.toIso8601String(),
        'cost': c.cost,
        'notes': c.notes,
      }).toList(),
      'vaccinationHistory': pet.vaccinationHistory.map((v) => {
        'id': v.id,
        'vaccineName': v.vaccineName,
        'date': v.date.toIso8601String(),
        'nextDueDate': v.nextDueDate?.toIso8601String(),
        'notes': v.notes,
      }).toList(),
      'accessoryHistory': pet.accessoryHistory.map((a) => {
        'id': a.id,
        'name': a.name,
        'type': a.type,
        'date': a.date.toIso8601String(),
        'cost': a.cost,
        'notes': a.notes,
      }).toList(),
      'foodHistory': pet.foodHistory.map((f) => {
        'id': f.id,
        'name': f.name,
        'type': f.type,
        'date': f.date.toIso8601String(),
        'cost': f.cost,
        'notes': f.notes,
      }).toList(),
      'foodInventory': pet.foodInventory.map((f) => {
        'id': f.id,
        'name': f.name,
        'type': f.type,
        'totalWeight': f.totalWeight,
        'remainingWeight': f.remainingWeight,
        'purchaseDate': f.purchaseDate.toIso8601String(),
        'cost': f.cost,
        'notes': f.notes,
      }).toList(),
      'mediaItems': pet.mediaItems.map((m) => {
        'id': m.id,
        'petId': m.petId,
        'type': m.type,
        'path': m.path,
        'date': m.date.toIso8601String(),
        'title': m.title,
      }).toList(),
    };
  }

  /// Chuyển đổi ScheduleRecord sang Map để lưu lên Firebase
  Map<String, dynamic> _scheduleToMap(ScheduleRecord schedule) {
    return {
      'id': schedule.id,
      'petId': schedule.petId,
      'title': schedule.title,
      'type': schedule.type,
      'date': schedule.date.toIso8601String(),
      'time': schedule.time,
      'notes': schedule.notes,
    };
  }

  /// Đồng bộ toàn bộ dữ liệu lên Firebase
  Future<void> syncAllDataToFirebase() async {
    if (!_syncService.isLoggedIn) return;

    try {
      // Đồng bộ tất cả thú cưng
      final petsMap = _pets.map((pet) => _petToMap(pet)).toList();
      await _syncService.syncAllPetsToFirebase(petsMap);
      
      print('All data synced to Firebase successfully');
    } catch (e) {
      print('Error syncing all data to Firebase: $e');
    }
  }

  /// Tải dữ liệu từ Firebase
  Future<void> loadDataFromFirebase() async {
    if (!_syncService.isLoggedIn) return;

    try {
      final pets = await _syncService.loadPetsFromFirebase();
      
      // TODO: Parse và load pets vào _pets
      print('Data loaded from Firebase: ${pets.length} pets');
    } catch (e) {
      print('Error loading data from Firebase: $e');
    }
  }

  // === FOOD INVENTORY MANAGEMENT ===
  
  /// Thêm thức ăn vào kho của thú cưng
  void addFoodToInventory(String petId, FoodInventory food) async {
    final pet = getPetById(petId);
    if (pet != null) {
      // Clone list và thêm food mới
      final updatedInventory = List<FoodInventory>.from(pet.foodInventory)..add(food);
      pet.foodInventory = updatedInventory;
      
      // Tạo FoodRecord từ inventory
      addFoodRecord(
        petId, 
        food.name, 
        food.type, 
        food.cost, 
        food.notes,
        date: food.purchaseDate,
      );
      
      notifyListeners();
      
      // Đồng bộ lên Firebase
      if (_syncService.isLoggedIn) {
        try {
          await _syncService.syncPetToFirebase(_petToMap(pet));
        } catch (e) {
          print('Error syncing pet to Firebase: $e');
        }
      }
    }
  }

  /// Cho thú cưng ăn - trừ số lượng thức ăn
  void feedPet(String petId, String foodId, double amount) async {
    final pet = getPetById(petId);
    if (pet != null) {
      final foodIndex = pet.foodInventory.indexWhere((f) => f.id == foodId);
      if (foodIndex != -1 && pet.foodInventory[foodIndex].remainingWeight >= amount) {
        final food = pet.foodInventory[foodIndex];
        food.remainingWeight -= amount;
        
        // Nếu hết thức ăn, tự động xóa
        if (food.remainingWeight <= 0) {
          pet.foodInventory.removeAt(foodIndex);
        }
        
        notifyListeners();
        
        // Ghi lại vào lịch sử ăn uống
        addFoodRecord(
          petId,
          food.name,
          food.type,
          null,
          'Đã cho ăn ${amount}kg',
          date: DateTime.now(),
        );
        
        // Đồng bộ lên Firebase
        if (_syncService.isLoggedIn) {
          try {
            await _syncService.syncPetToFirebase(_petToMap(pet));
          } catch (e) {
            print('Error syncing pet to Firebase: $e');
          }
        }
      }
    }
  }

  /// Lấy danh sách thức ăn của thú cưng
  List<FoodInventory> getFoodInventory(String petId) {
    final pet = getPetById(petId);
    return pet?.foodInventory ?? [];
  }
}




