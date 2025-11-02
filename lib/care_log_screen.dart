// lib/care_log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'pet_service.dart';
import 'fab_location.dart';
import 'dart:io';

class CareLogScreen extends StatefulWidget {
  final Function(String?)? onPetIdChanged; // Callback để truyền selectedPetId cho HomePage
  
  const CareLogScreen({super.key, this.onPetIdChanged});

  @override
  State<CareLogScreen> createState() => _CareLogScreenState();
}

class _CareLogScreenState extends State<CareLogScreen> {
  String? _selectedPetId;
  String _selectedLogType = 'all'; // 'all', 'weight', 'care', 'vaccination', 'accessory', 'food'

  @override
  Widget build(BuildContext context) {
    final petService = context.watch<PetService>();
    final pets = petService.pets;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Column(
            children: [
              // Hiển thị danh sách thú cưng hoặc timeline
              Expanded(
                child: _selectedPetId == null
                    // Hiển thị danh sách thú cưng để chọn
                    ? Container(
                        color: Colors.grey[50],
                        child: pets.isEmpty
                            ? Center(
                                child: Text('no_pets_yet'.tr()),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
                                itemCount: pets.length,
                                itemBuilder: (context, index) {
                                  final pet = pets[index];
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.teal[100],
                                        backgroundImage: pet.imageUrl != null ? FileImage(File(pet.imageUrl!)) : null,
                                        child: pet.imageUrl == null
                                            ? const Icon(Icons.pets, color: Colors.teal)
                                            : null,
                                      ),
                                      title: Text(
                                        pet.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text('${pet.species} - ${pet.breed}'),
                                      onTap: () {
                                        setState(() {
                                          _selectedPetId = pet.id;
                                        });
                                        // Thông báo cho HomePage
                                        if (widget.onPetIdChanged != null) {
                                          widget.onPetIdChanged!(pet.id);
                                        }
                                      },
                                      trailing: const Icon(Icons.chevron_right),
                                    ),
                                  );
                                },
                              ),
                      )
                    // Hiển thị timeline
                    : Stack(
                        children: [
                          _buildTimeline(petService),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedPetId = null;
                                });
                                // Thông báo cho HomePage
                                if (widget.onPetIdChanged != null) {
                                  widget.onPetIdChanged!(null);
                                }
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: Text('go_back'.tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              ),
                            )
                                .animate()
                                ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(PetService petService) {
    final pet = petService.getPetById(_selectedPetId!);
    if (pet == null) return const SizedBox.shrink();

    final allLogs = <Map<String, dynamic>>[];
    
    // Add weight logs
    for (final weight in pet.weightHistory) {
      allLogs.add({
        'type': 'weight',
        'title': '${'weight_colon'.tr()}: ${weight.weight}kg',
        'date': weight.date,
        'notes': weight.notes,
        'icon': Icons.monitor_weight,
        'color': Colors.blue,
      });
    }
    
    // Add care logs
    for (final care in pet.careHistory) {
      allLogs.add({
        'type': 'care',
        'title': care.type,
        'date': care.date,
        'notes': care.notes,
        'cost': care.cost,
        'icon': Icons.healing,
        'color': Colors.green,
      });
    }
    
    // Add vaccination logs
    for (final vaccination in pet.vaccinationHistory) {
      allLogs.add({
        'type': 'vaccination',
        'title': vaccination.vaccineName,
        'date': vaccination.date,
        'notes': vaccination.notes,
        'icon': Icons.medical_services,
        'color': Colors.red,
      });
    }
    
    // Add accessory logs
    for (final accessory in pet.accessoryHistory) {
      allLogs.add({
        'type': 'accessory',
        'title': accessory.name,
        'date': accessory.date,
        'notes': accessory.notes,
        'cost': accessory.cost,
        'icon': Icons.shopping_bag,
        'color': Colors.orange,
      });
    }
    
    // Add food logs
    for (final food in pet.foodHistory) {
      allLogs.add({
        'type': 'food',
        'title': food.name,
        'date': food.date,
        'notes': food.notes,
        'cost': food.cost,
        'icon': Icons.restaurant,
        'color': Colors.purple,
      });
    }

    // Sort by date (newest first)
    allLogs.sort((a, b) => b['date'].compareTo(a['date']));
    
    // Filter by type
    final filteredLogs = _filterLogs(allLogs);

    if (filteredLogs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có nhật ký nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Nhấn nút + để thêm nhật ký mới',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        final log = filteredLogs[index];
        final isFirst = index == 0;
        final isLast = index == filteredLogs.length - 1;
        
        return TimelineTile(
          isFirst: isFirst,
          isLast: isLast,
          beforeLineStyle: LineStyle(
            color: log['color'],
            thickness: 2,
          ),
          indicatorStyle: IndicatorStyle(
            width: 20,
            height: 20,
            indicator: Container(
              decoration: BoxDecoration(
                color: log['color'],
                shape: BoxShape.circle,
              ),
              child: Icon(
                log['icon'],
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
          endChild: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(log['icon'], color: log['color']),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          log['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${log['date'].day}/${log['date'].month}/${log['date'].year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (log['cost'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${'cost_colon'.tr()}${log['cost'].toStringAsFixed(0)}${'vnd_short'.tr()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (log['notes'] != null && log['notes'].isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      log['notes'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        )
            ;
      },
    );
  }

  List<Map<String, dynamic>> _filterLogs(List<Map<String, dynamic>> logs) {
    switch (_selectedLogType) {
      case 'weight':
        return logs.where((log) => log['type'] == 'weight').toList();
      case 'care':
        return logs.where((log) => log['type'] == 'care').toList();
      case 'vaccination':
        return logs.where((log) => log['type'] == 'vaccination').toList();
      case 'accessory':
        return logs.where((log) => log['type'] == 'accessory').toList();
      case 'food':
        return logs.where((log) => log['type'] == 'food').toList();
      default:
        return logs;
    }
  }

  void _showAddLogDialog(BuildContext context, PetService petService) {
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_select_pet'.tr())),
      );
      return;
    }

    String? selectedLogType;
    final notesController = TextEditingController();
    final valueController = TextEditingController();
    final stt.SpeechToText _speech = stt.SpeechToText();
    bool _isListening = false;
    bool _isListeningNotes = false;

    void _toggleListening(bool forNotes) async {
      // Phát âm thanh feedback nhẹ khi bấm mic
      SystemSound.play(SystemSoundType.click);
      
      if (!_isListening && !_isListeningNotes) {
        // Start listening
        bool available = await _speech.initialize(
          onStatus: (val) {
            if (val == 'done') {
              if (forNotes) {
                _isListeningNotes = false;
              } else {
                _isListening = false;
              }
              (context as Element).markNeedsBuild();
            }
          },
          onError: (val) {},
        );

        if (available) {
          // Get available locales and check for Vietnamese support
          List<stt.LocaleName> locales = await _speech.locales();
          String localeId = 'vi_VN'; // Vietnamese locale
          
          // Check if Vietnamese is available, otherwise use system default
          bool isVietnameseAvailable = locales.any((locale) => 
              locale.localeId.toLowerCase().contains('vi'));
          
          if (forNotes) {
            _isListeningNotes = true;
          } else {
            _isListening = true;
          }
          
          await _speech.listen(
            onResult: (val) {
              if (forNotes) {
                notesController.text = val.recognizedWords;
              } else {
                valueController.text = val.recognizedWords;
              }
            },
            localeId: isVietnameseAvailable ? localeId : null,
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 3),
          );
        }
      } else {
        // Stop listening - phát âm thanh kết thúc
        SystemSound.play(SystemSoundType.click);
        await _speech.stop();
        if (forNotes) {
          _isListeningNotes = false;
        } else {
          _isListening = false;
        }
      }
      (context as Element).markNeedsBuild();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('add_log'.tr()),
            content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'care_log_type'.tr()),
                  items: [
                    DropdownMenuItem(value: 'weight', child: Text('weight'.tr())),
                    DropdownMenuItem(value: 'care', child: Text('care'.tr())),
                    DropdownMenuItem(value: 'vaccination', child: Text('vaccination'.tr())),
                    DropdownMenuItem(value: 'accessory', child: Text('accessories'.tr())),
                    DropdownMenuItem(value: 'food', child: Text('food'.tr())),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedLogType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedLogType == 'weight') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: valueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'weight_kg'.tr(),
                            hintText: 'Nói "5 kg" hoặc nhập số',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : Colors.teal,
                        ),
                        onPressed: () => _toggleListening(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else if (selectedLogType == 'care') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: valueController,
                          decoration: InputDecoration(
                            labelText: 'care_type'.tr(),
                            hintText: 'Nói "Khám sức khỏe định kỳ" hoặc nhập',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : Colors.teal,
                        ),
                        onPressed: () => _toggleListening(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else if (selectedLogType == 'vaccination') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: valueController,
                          decoration: InputDecoration(
                            labelText: 'vaccine_name'.tr(),
                            hintText: 'Nói "Vaccin dại" hoặc nhập',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : Colors.teal,
                        ),
                        onPressed: () => _toggleListening(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else if (selectedLogType == 'accessory') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: valueController,
                          decoration: InputDecoration(
                            labelText: 'accessory_name'.tr(),
                            hintText: 'Nói "Vòng cổ da" hoặc nhập',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : Colors.teal,
                        ),
                        onPressed: () => _toggleListening(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else if (selectedLogType == 'food') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: valueController,
                          decoration: InputDecoration(
                            labelText: 'food_name'.tr(),
                            hintText: 'Nói "Thức ăn khô hạt nhỏ" hoặc nhập',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : Colors.teal,
                        ),
                        onPressed: () => _toggleListening(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: notesController,
                        decoration: InputDecoration(
                          labelText: 'log_note'.tr(),
                          hintText: 'Nói ghi chú dài hoặc nhập...',
                        ),
                        maxLines: 3,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isListeningNotes ? Icons.mic : Icons.mic_none,
                        color: _isListeningNotes ? Colors.red : Colors.teal,
                      ),
                      onPressed: () => _toggleListening(true),
                    ),
                  ],
                ),
                if (_isListening || _isListeningNotes) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Đang nghe... Hãy nói rõ ràng',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ],
              ],
            ),
            ),
            actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedLogType == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng chọn loại nhật ký')),
                );
                return;
              }

              // Kiểm tra validation cụ thể cho từng loại
              bool isValid = true;
              String errorMessage = '';

              switch (selectedLogType) {
                case 'weight':
                  final weight = double.tryParse(valueController.text.trim());
                  if (weight == null || weight <= 0) {
                    isValid = false;
                    errorMessage = 'Vui lòng nhập cân nặng hợp lệ';
                  }
                  break;
                case 'care':
                  if (valueController.text.trim().isEmpty) {
                    isValid = false;
                    errorMessage = 'Vui lòng nhập loại chăm sóc';
                  }
                  break;
                case 'vaccination':
                  if (valueController.text.trim().isEmpty) {
                    isValid = false;
                    errorMessage = 'Vui lòng nhập tên vaccine';
                  }
                  break;
                case 'accessory':
                  if (valueController.text.trim().isEmpty) {
                    isValid = false;
                    errorMessage = 'Vui lòng nhập tên phụ kiện';
                  }
                  break;
                case 'food':
                  if (valueController.text.trim().isEmpty) {
                    isValid = false;
                    errorMessage = 'Vui lòng nhập tên thức ăn';
                  }
                  break;
              }

              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
                return;
              }

              // Thêm dữ liệu vào PetService
              switch (selectedLogType) {
                case 'weight':
                  final weight = double.parse(valueController.text.trim());
                  petService.addWeightRecord(
                    _selectedPetId!,
                    weight,
                    notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  );
                  break;
                case 'care':
                  petService.addCareRecord(
                    _selectedPetId!,
                    valueController.text.trim(),
                    null,
                    notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  );
                  break;
                case 'vaccination':
                  petService.addVaccinationRecord(
                    _selectedPetId!,
                    valueController.text.trim(),
                    null,
                    notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  );
                  break;
                case 'accessory':
                  petService.addAccessoryRecord(
                    _selectedPetId!,
                    valueController.text.trim(),
                    'Phụ kiện',
                    null,
                    notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  );
                  break;
                case 'food':
                  petService.addFoodRecord(
                    _selectedPetId!,
                    valueController.text.trim(),
                    'Thức ăn',
                    null,
                    notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  );
                  break;
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm nhật ký thành công!')),
              );
            },
            child: Text('add'.tr()),
          ),
        ],
          );
        },
      ),
    );
  }
}




