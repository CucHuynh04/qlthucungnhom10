// lib/food_inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'sound_helper.dart';
import 'pet_service.dart';
import 'fab_location.dart';
import 'dart:io';

class FoodInventoryScreen extends StatefulWidget {
  final Function(String?)? onPetIdChanged; // Callback để truyền selectedPetId cho HomePage
  
  const FoodInventoryScreen({super.key, this.onPetIdChanged});

  @override
  State<FoodInventoryScreen> createState() => _FoodInventoryScreenState();
}

class _FoodInventoryScreenState extends State<FoodInventoryScreen> {
  String? _selectedPetId;
  String? _selectedFoodId; // Thức ăn đang chọn để cho ăn
  
  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isListeningNotes = false;

  @override
  Widget build(BuildContext context) {
    final petService = context.watch<PetService>();
    final pets = petService.pets;

    return Scaffold(
      extendBody: true,
      // Không có appBar vì HomePage đã có AppBar rồi
      body: _selectedPetId == null
          ? _buildPetSelection(pets)
          : _buildFoodInventory(petService),
      // FAB được quản lý bởi HomePage
    );
  }

  Widget _buildPetSelection(List<Pet> pets) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildFoodInventory(PetService petService) {
    final pet = petService.getPetById(_selectedPetId!);
    if (pet == null) return const SizedBox.shrink();

    // Lấy inventory thức ăn thực tế từ pet
    final inventory = pet.foodInventory;

    return Stack(
      children: [
        if (inventory.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fastfood, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'no_food_inventory'.tr(),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'tap_add_to_add_food'.tr(),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final food = inventory[index];
                    final isLowStock = food.remainingPercentage < 20;
                    
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: food.remainingPercentage > 50
                              ? Colors.green[100]
                              : isLowStock
                                  ? Colors.red[100]
                                  : Colors.orange[100],
                          child: Icon(
                            Icons.fastfood,
                            color: food.remainingPercentage > 50
                                ? Colors.green[700]
                                : isLowStock
                                    ? Colors.red[700]
                                    : Colors.orange[700],
                          ),
                        ),
                        title: Text(
                          food.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${'remaining'.tr()}: ${food.remainingWeight.toStringAsFixed(2)} kg / ${food.totalWeight} kg'),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: food.remainingPercentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                food.remainingPercentage > 50
                                    ? Colors.green
                                    : isLowStock
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${food.remainingMeals} ${'meals_remaining'.tr()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.restaurant,
                            color: food.remainingWeight > 0 ? Colors.teal : Colors.grey,
                          ),
                          onPressed: food.remainingWeight > 0
                              ? () => _showFeedDialog(context, food, petService)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        // Nút quay lại - luôn hiển thị ở góc trên bên trái
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
          ).animate(),
        ),
      ],
    );
  }

  void _showFeedDialog(BuildContext context, FoodInventory food, PetService petService) {
    final amountController = TextEditingController(text: '0.05');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('feed_pet'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${'feeding'.tr()}: ${food.name}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'amount_kg'.tr(),
                        hintText: '0.05',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : Colors.teal,
                    ),
                    onPressed: () => _toggleListening(amountController),
                  ),
                ],
              ),
              if (_isListening) ...[
                const SizedBox(height: 8),
                Text(
                  'Đang nghe... Hãy nói "0.05 kg" hoặc nhập số',
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0 || amount > food.remainingWeight) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Số lượng không hợp lệ')),
                  );
                  return;
                }

                // Cho thú cưng ăn - trừ số lượng thức ăn
                petService.feedPet(_selectedPetId!, food.id, amount);
                
                Navigator.pop(context);
                SoundHelper.playSuccessSound();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${'fed'.tr()}: ${amount} kg')),
                );
              },
              child: Text('feed'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog(BuildContext context, PetService petService) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final weightController = TextEditingController();
    final costController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDate;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('add_food'.tr(), style: const TextStyle(fontSize: 18)),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  // Tên thức ăn với speech-to-text
                  _buildTextFieldWithMic(
                    nameController,
                    'food_name'.tr(),
                    'Nói "Thức ăn khô hạt nhỏ" hoặc nhập',
                    false,
                    setState,
                  ),
                  const SizedBox(height: 16),
                  // Loại thức ăn với speech-to-text
                  _buildTextFieldWithMic(
                    typeController,
                    'food_type'.tr(),
                    'Nói "Khô" hoặc nhập',
                    false,
                    setState,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'total_weight_kg'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.scale),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: costController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'cost_vnd'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Chọn ngày mua
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.teal, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedDate != null
                                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                  : 'Chọn ngày',
                              style: TextStyle(
                                color: selectedDate != null ? Colors.black : Colors.grey[600],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Ghi chú với speech-to-text
                  _buildNotesFieldWithMic(
                    notesController,
                    'notes_optional'.tr(),
                    'Nói ghi chú dài hoặc nhập...',
                    setState,
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
                final name = nameController.text.trim();
                final type = typeController.text.trim();
                final weight = double.tryParse(weightController.text.trim());
                final cost = double.tryParse(costController.text.trim());

                if (name.isEmpty || type.isEmpty || weight == null || weight <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                  );
                  return;
                }

                // Thêm thức ăn vào inventory
                final food = FoodInventory(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  type: type,
                  totalWeight: weight,
                  remainingWeight: weight,
                  purchaseDate: selectedDate ?? DateTime.now(),
                  cost: cost,
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );

                petService.addFoodToInventory(_selectedPetId!, food);
                
                Navigator.pop(context);
                SoundHelper.playSuccessSound();
                
                // Force rebuild để hiển thị thức ăn mới ngay lập tức
                if (mounted) {
                  setState(() {});
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã thêm thức ăn!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('add'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithMic(TextEditingController controller, String label, String hint, bool forNotes, StateSetter setState) {
    return Row(
      crossAxisAlignment: forNotes ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: forNotes ? 3 : 1,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(
            (_isListening && !forNotes) || (_isListeningNotes && forNotes) 
                ? Icons.mic 
                : Icons.mic_none,
            color: (_isListening && !forNotes) || (_isListeningNotes && forNotes)
                ? Colors.red
                : Colors.teal,
          ),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
          onPressed: () => _toggleListeningForDialog(controller, forNotes, setState),
        ),
      ],
    );
  }

  Widget _buildNotesFieldWithMic(TextEditingController controller, String label, String hint, StateSetter setState) {
    return _buildTextFieldWithMic(controller, label, hint, true, setState);
  }

  Future<void> _toggleListeningForDialog(TextEditingController controller, bool forNotes, StateSetter setState) async {
    SystemSound.play(SystemSoundType.click);
    
    if (!_isListening && !_isListeningNotes) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            setState(() {
              if (forNotes) {
                _isListeningNotes = false;
              } else {
                _isListening = false;
              }
            });
          }
        },
        onError: (val) {},
      );

      if (available) {
        List<stt.LocaleName> locales = await _speech.locales();
        String localeId = 'vi_VN';
        bool isVietnameseAvailable = locales.any((locale) => 
            locale.localeId.toLowerCase().contains('vi'));
        
        setState(() {
          if (forNotes) {
            _isListeningNotes = true;
          } else {
            _isListening = true;
          }
        });
        
        await _speech.listen(
          onResult: (val) {
            controller.text = val.recognizedWords;
          },
          localeId: isVietnameseAvailable ? localeId : null,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      }
    } else {
      SystemSound.play(SystemSoundType.click);
      await _speech.stop();
      setState(() {
        if (forNotes) {
          _isListeningNotes = false;
        } else {
          _isListening = false;
        }
      });
    }
  }

  Future<void> _toggleListening(TextEditingController controller) async {
    SystemSound.play(SystemSoundType.click);
    
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            setState(() {
              _isListening = false;
            });
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
        
        setState(() {
          _isListening = true;
        });
        
        await _speech.listen(
          onResult: (val) {
            controller.text = val.recognizedWords;
          },
          localeId: isVietnameseAvailable ? localeId : null,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      }
    } else {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }
}






