// lib/add_data_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'pet_service.dart';
import 'dart:io';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  String? _selectedPetId;
  String _selectedDataType = 'weight'; // 'weight', 'care', 'vaccination', 'accessory', 'pet'
  
  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isListeningNotes = false;
  
  // Controllers cho form cân nặng
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _weightNotesController = TextEditingController();
  
  // Controllers cho form chăm sóc
  final TextEditingController _careTypeController = TextEditingController();
  final TextEditingController _careCostController = TextEditingController();
  final TextEditingController _careNotesController = TextEditingController();
  
  // Controllers cho form tiêm chủng
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _vaccinationNotesController = TextEditingController();
  DateTime? _nextDueDate;
  
  // Controllers cho form phụ kiện
  final TextEditingController _accessoryNameController = TextEditingController();
  final TextEditingController _accessoryTypeController = TextEditingController();
  final TextEditingController _accessoryCostController = TextEditingController();
  final TextEditingController _accessoryNotesController = TextEditingController();
  
  // Thời gian cho các loại dữ liệu
  DateTime? _selectedWeightDate;
  DateTime? _selectedCareDate;
  DateTime? _selectedVaccinationDate;
  DateTime? _selectedAccessoryDate;
  

  @override
  Widget build(BuildContext context) {
    final petService = context.watch<PetService>();
    final pets = petService.pets;
    print('AddDataScreen build: ${pets.length} pets available');

    return Scaffold(
      body: Column(
        children: [
          // Bộ chọn loại dữ liệu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                
                // Các button loại dữ liệu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDataType = 'weight';
                          });
                        },
                        icon: const Icon(Icons.monitor_weight),
                        label: Text('weight'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDataType == 'weight' ? Colors.teal[700] : Colors.grey[300],
                          foregroundColor: _selectedDataType == 'weight' ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      )
                          .animate()
                          ,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDataType = 'care';
                          });
                        },
                        icon: const Icon(Icons.healing),
                        label: Text('care'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDataType == 'care' ? Colors.teal[700] : Colors.grey[300],
                          foregroundColor: _selectedDataType == 'care' ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      )
                          .animate()
                          ,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDataType = 'vaccination';
                          });
                        },
                        icon: const Icon(Icons.medical_services),
                        label: Text('vaccination'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDataType == 'vaccination' ? Colors.teal[700] : Colors.grey[300],
                          foregroundColor: _selectedDataType == 'vaccination' ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      )
                          .animate()
                          ,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDataType = 'accessory';
                          });
                        },
                        icon: const Icon(Icons.shopping_bag),
                        label: Text('accessories'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDataType == 'accessory' ? Colors.teal[700] : Colors.grey[300],
                          foregroundColor: _selectedDataType == 'accessory' ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      )
                          .animate()
                          ,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Hiển thị danh sách thú cưng hoặc form
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
                            key: ValueKey('pets_list_${pets.length}'), // Force rebuild when pets list changes
                            padding: const EdgeInsets.all(10),
                            itemCount: pets.length,
                            itemBuilder: (context, index) {
                              final pet = pets[index];
                              print('Building pet item: ${pet.id}, ${pet.name}');
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
                                    print('Pet selected: ${pet.id}, ${pet.name}');
                                    setState(() {
                                      _selectedPetId = pet.id;
                                    });
                                    // Đảm bảo form được rebuild
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              );
                            },
                          ),
                  )
                // Hiển thị form nhập dữ liệu
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nút quay lại
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedPetId = null;
                            });
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: Text('back_to_pet_selection'.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                        )
                            .animate(), const SizedBox(height: 16),
                        // Form
                        _buildActualForm()
                            .animate()
                            .slideY(begin: 0.3, end: 0),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActualForm() {
    switch (_selectedDataType) {
      case 'weight':
        return _buildWeightForm();
      case 'care':
        return _buildCareForm();
      case 'vaccination':
        return _buildVaccinationForm();
      case 'accessory':
        return _buildAccessoryForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWeightForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'add_weight_data'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
      
        _buildTextFieldWithMic(
          _weightController,
          'weight_kg'.tr(),
          'Nói "5 kg" hoặc nhập số',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        
        // Chọn ngày cho cân nặng
        _buildDateSelector('weight', _selectedWeightDate),
        const SizedBox(height: 16),
        
        _buildNotesFieldWithMic(
          _weightNotesController,
          'notes_optional'.tr(),
          'Nói ghi chú dài hoặc nhập...',
        ),
        if (_isListening || _isListeningNotes) ...[
          const SizedBox(height: 8),
          Text(
            'Đang nghe... Hãy nói rõ ràng',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
        ],
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              print('Add weight button pressed, selectedPetId: $_selectedPetId');
              _addWeightData();
            },
            icon: const Icon(Icons.add),
            label: Text('add_weight_data'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCareForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'add_care_form_title'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        _buildTextFieldWithMic(
          _careTypeController,
          'care_type'.tr(),
          'Nói "Khám sức khỏe định kỳ" hoặc nhập',
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _careCostController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'cost_vnd'.tr(),
            hintText: 'cost_hint'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.account_balance_wallet),
          ),
        ),
        const SizedBox(height: 16),
        
        // Chọn ngày cho chăm sóc
        _buildDateSelector('care', _selectedCareDate),
        const SizedBox(height: 16),
        
        _buildNotesFieldWithMic(
          _careNotesController,
          'notes_optional'.tr(),
          'Nói ghi chú dài hoặc nhập...',
        ),
        if (_isListening || _isListeningNotes) ...[
          const SizedBox(height: 8),
          Text(
            'Đang nghe... Hãy nói rõ ràng',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
        ],
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              print('Add care button pressed, selectedPetId: $_selectedPetId');
              _addCareData();
            },
            icon: const Icon(Icons.add),
            label: Text('add_care_form_title'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVaccinationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'add_vaccination_form_title'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        _buildTextFieldWithMic(
          _vaccineNameController,
          'vaccine_name'.tr(),
          'Nói "Vaccin dại" hoặc nhập',
        ),
        const SizedBox(height: 16),
        
        // Chọn ngày tiêm chủng
        _buildDateSelector('vaccination', _selectedVaccinationDate),
        const SizedBox(height: 16),
        
        InkWell(
          onTap: _selectNextDueDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _nextDueDate != null
                        ? 'Ngày tiêm tiếp theo: ${_nextDueDate!.day}/${_nextDueDate!.month}/${_nextDueDate!.year}'
                        : 'Chọn ngày tiêm tiếp theo (tùy chọn)',
                    style: TextStyle(
                      color: _nextDueDate != null ? Colors.black : Colors.grey[600],
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        _buildNotesFieldWithMic(
          _vaccinationNotesController,
          'notes_optional'.tr(),
          'Nói ghi chú dài hoặc nhập...',
        ),
        if (_isListening || _isListeningNotes) ...[
          const SizedBox(height: 8),
          Text(
            'Đang nghe... Hãy nói rõ ràng',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
        ],
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              print('Add vaccination button pressed, selectedPetId: $_selectedPetId');
              _addVaccinationData();
            },
            icon: const Icon(Icons.add),
            label: Text('add_vaccination_form_title'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectNextDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    
    if (date != null) {
      setState(() {
        _nextDueDate = date;
      });
    }
  }

  void _addWeightData() {
    print('_addWeightData called, _selectedPetId: $_selectedPetId');
    
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thú cưng trước khi thêm dữ liệu')),
      );
      return;
    }
    
    final weightText = _weightController.text.trim();
    if (weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập cân nặng')),
      );
      return;
    }

    final weight = double.tryParse(weightText);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cân nặng không hợp lệ')),
      );
      return;
    }

    final petService = context.read<PetService>();
    print('Available pets: ${petService.pets.map((p) => '${p.id}:${p.name}').toList()}');
    
    // Kiểm tra thú cưng có tồn tại không
    final pet = petService.getPetById(_selectedPetId!);
    print('Found pet: ${pet?.name}');
    
    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy thú cưng (ID: $_selectedPetId). Vui lòng chọn lại thú cưng.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {
        _selectedPetId = null; // Reset về màn hình chọn thú cưng
      });
      return;
    }
    
    try {
      petService.addWeightRecord(
        _selectedPetId!,
        weight,
        _weightNotesController.text.trim().isEmpty ? null : _weightNotesController.text.trim(),
        date: _selectedWeightDate,
      );

      _weightController.clear();
      _weightNotesController.clear();
      _selectedWeightDate = null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm dữ liệu cân nặng thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error adding weight data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thêm dữ liệu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _addCareData() {
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thú cưng trước khi thêm dữ liệu')),
      );
      return;
    }
    
    final careType = _careTypeController.text.trim();
    if (careType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập loại chăm sóc')),
      );
      return;
    }

    final costText = _careCostController.text.trim();
    double? cost;
    if (costText.isNotEmpty) {
      cost = double.tryParse(costText);
      if (cost == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chi phí không hợp lệ')),
        );
        return;
      }
    }

    final petService = context.read<PetService>();
    // Kiểm tra thú cưng có tồn tại không
    final pet = petService.getPetById(_selectedPetId!);
    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thú cưng. Vui lòng chọn lại thú cưng.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _selectedPetId = null; // Reset về màn hình chọn thú cưng
      });
      return;
    }
    
    petService.addCareRecord(
      _selectedPetId!,
      careType,
      cost,
      _careNotesController.text.trim().isEmpty ? null : _careNotesController.text.trim(),
      date: _selectedCareDate,
    );

    _careTypeController.clear();
    _careCostController.clear();
    _careNotesController.clear();
    _selectedCareDate = null;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm dữ liệu chăm sóc thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _addVaccinationData() {
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thú cưng trước khi thêm dữ liệu')),
      );
      return;
    }
    
    final vaccineName = _vaccineNameController.text.trim();
    if (vaccineName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên vaccine')),
      );
      return;
    }

    final petService = context.read<PetService>();
    // Kiểm tra thú cưng có tồn tại không
    final pet = petService.getPetById(_selectedPetId!);
    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thú cưng. Vui lòng chọn lại thú cưng.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _selectedPetId = null; // Reset về màn hình chọn thú cưng
      });
      return;
    }
    
    petService.addVaccinationRecord(
      _selectedPetId!,
      vaccineName,
      _nextDueDate,
      _vaccinationNotesController.text.trim().isEmpty ? null : _vaccinationNotesController.text.trim(),
      date: _selectedVaccinationDate,
    );

    _vaccineNameController.clear();
    _vaccinationNotesController.clear();
    _nextDueDate = null;
    _selectedVaccinationDate = null;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm dữ liệu tiêm chủng thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildAccessoryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'add_accessory_form_title'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        _buildTextFieldWithMic(
          _accessoryNameController,
          'accessory_name'.tr(),
          'Nói "Vòng cổ da" hoặc nhập',
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _accessoryTypeController,
          decoration: InputDecoration(
            labelText: 'accessory_type'.tr(),
            hintText: 'accessory_type_hint'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.category),
          ),
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _accessoryCostController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'cost_vnd'.tr(),
            hintText: 'cost_hint'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.account_balance_wallet),
          ),
        ),
        const SizedBox(height: 16),
        
        // Chọn ngày cho phụ kiện
        _buildDateSelector('accessory', _selectedAccessoryDate),
        const SizedBox(height: 16),
        
        _buildNotesFieldWithMic(
          _accessoryNotesController,
          'notes_optional'.tr(),
          'Nói ghi chú dài hoặc nhập...',
        ),
        if (_isListening || _isListeningNotes) ...[
          const SizedBox(height: 8),
          Text(
            'Đang nghe... Hãy nói rõ ràng',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
        ],
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              print('Add accessory button pressed, selectedPetId: $_selectedPetId');
              _addAccessoryData();
            },
            icon: const Icon(Icons.add),
            label: Text('add_accessory_form_title'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addAccessoryData() {
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thú cưng trước khi thêm dữ liệu')),
      );
      return;
    }
    
    final name = _accessoryNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên phụ kiện')),
      );
      return;
    }

    final type = _accessoryTypeController.text.trim();
    if (type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập loại phụ kiện')),
      );
      return;
    }

    final costText = _accessoryCostController.text.trim();
    double? cost;
    if (costText.isNotEmpty) {
      cost = double.tryParse(costText);
      if (cost == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chi phí không hợp lệ')),
        );
        return;
      }
    }

    final petService = context.read<PetService>();
    // Kiểm tra thú cưng có tồn tại không
    final pet = petService.getPetById(_selectedPetId!);
    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thú cưng. Vui lòng chọn lại thú cưng.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _selectedPetId = null; // Reset về màn hình chọn thú cưng
      });
      return;
    }
    
    petService.addAccessoryRecord(
      _selectedPetId!,
      name,
      type,
      cost,
      _accessoryNotesController.text.trim().isEmpty ? null : _accessoryNotesController.text.trim(),
      date: _selectedAccessoryDate,
    );

    _accessoryNameController.clear();
    _accessoryTypeController.clear();
    _accessoryCostController.clear();
    _accessoryNotesController.clear();
    _selectedAccessoryDate = null;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm phụ kiện thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }



  Widget _buildDateSelector(String type, DateTime? selectedDate) {
    return InkWell(
      onTap: () => _selectDate(context, type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.teal, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                selectedDate != null
                    ? 'Ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : 'Chọn ngày (mặc định: hôm nay)',
                style: TextStyle(
                  color: selectedDate != null ? Colors.black : Colors.grey[600],
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        switch (type) {
          case 'weight':
            _selectedWeightDate = picked;
            break;
          case 'care':
            _selectedCareDate = picked;
            break;
          case 'vaccination':
            _selectedVaccinationDate = picked;
            break;
          case 'accessory':
            _selectedAccessoryDate = picked;
            break;
        }
      });
    }
  }

  Future<void> _toggleListening(bool forNotes, TextEditingController controller) async {
    // Phát âm thanh feedback nhẹ khi bấm mic
    SystemSound.play(SystemSoundType.click);
    
    if (!_isListening && !_isListeningNotes) {
      // Start listening
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
        // Get available locales and check for Vietnamese support
        List<stt.LocaleName> locales = await _speech.locales();
        String localeId = 'vi_VN'; // Vietnamese locale
        
        // Check if Vietnamese is available, otherwise use system default
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
      // Stop listening - phát âm thanh kết thúc
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

  Widget _buildTextFieldWithMic(TextEditingController controller, String label, String hint, {TextInputType? keyboardType}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
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
            _isListening ? Icons.mic : Icons.mic_none,
            color: _isListening ? Colors.red : Colors.teal,
          ),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
          onPressed: () => _toggleListening(false, controller),
        ),
      ],
    );
  }

  Widget _buildNotesFieldWithMic(TextEditingController controller, String label, String hint) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: 3,
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
            _isListeningNotes ? Icons.mic : Icons.mic_none,
            color: _isListeningNotes ? Colors.red : Colors.teal,
          ),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
          onPressed: () => _toggleListening(true, controller),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _weightNotesController.dispose();
    _careTypeController.dispose();
    _careCostController.dispose();
    _careNotesController.dispose();
    _vaccineNameController.dispose();
    _vaccinationNotesController.dispose();
    _accessoryNameController.dispose();
    _accessoryTypeController.dispose();
    _accessoryCostController.dispose();
    _accessoryNotesController.dispose();
    _speech.stop();
    super.dispose();
  }
}





