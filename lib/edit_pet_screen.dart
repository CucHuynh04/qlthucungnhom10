import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'pet_service.dart';
import 'dart:io';

class EditPetScreen extends StatefulWidget {
  final Pet pet;

  const EditPetScreen({super.key, required this.pet});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _genderController;
  late TextEditingController _birthDateController;
  late TextEditingController _weightController;
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _speciesController = TextEditingController(text: widget.pet.species);
    _breedController = TextEditingController(text: widget.pet.breed);
    _genderController = TextEditingController(text: widget.pet.gender);
    _birthDateController = TextEditingController(text: widget.pet.birthDate);
    _weightController = TextEditingController(
      text: widget.pet.weight?.toStringAsFixed(1) ?? '',
    );
    _imagePath = widget.pet.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _genderController.dispose();
    _birthDateController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa ${widget.pet.name}'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: Text(
              'Lưu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet image section
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  
                  // Basic information
                  _buildSectionTitle('Thông tin cơ bản'),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _nameController,
                    label: 'Tên thú cưng',
                    hint: 'Ví dụ: Miu, Gâu...',
                    icon: Icons.pets,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _speciesController,
                    label: 'Loài',
                    hint: 'Ví dụ: Mèo, Chó, Chim...',
                    icon: Icons.category,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _breedController,
                    label: 'Giống',
                    hint: 'Ví dụ: Anh Lông Ngắn, Poodle...',
                    icon: Icons.pets,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _genderController,
                    label: 'Giới tính',
                    hint: 'Ví dụ: Đực, Cái...',
                    icon: Icons.wc,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _birthDateController,
                    label: 'Ngày sinh (DD/MM/YYYY)',
                    hint: 'Ví dụ: 10/10/2023',
                    icon: Icons.cake,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _weightController,
                    label: 'Cân nặng (kg)',
                    hint: 'Ví dụ: 5.5',
                    icon: Icons.monitor_weight,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveChanges,
                          icon: const Icon(Icons.save),
                          label: Text('save_changes'.tr()),
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _cancelEdit,
                          icon: const Icon(Icons.cancel),
                          label: Text('cancel'.tr()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal[700],
                            side: BorderSide(color: Colors.teal[700]!),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal[100],
                border: Border.all(
                  color: Colors.teal[300]!,
                  width: 2,
                ),
              ),
              child: _imagePath != null
                  ? ClipOval(
                      child: Image.file(
                        File(_imagePath!),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.pets,
                            size: 60,
                            color: Colors.teal[700],
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.pets,
                      size: 60,
                      color: Colors.teal[700],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt),
            label: Text('change_photo'.tr()),
            style: TextButton.styleFrom(
              foregroundColor: Colors.teal[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.teal[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show options dialog
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn ảnh từ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('camera'.tr()),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('photo_library'.tr()),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            _imagePath = image.path;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã chọn ảnh thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (_isLoading) return;

    // Validate input
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập tên thú cưng');
      return;
    }
    if (_speciesController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập loài');
      return;
    }
    if (_breedController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập giống');
      return;
    }
    if (_genderController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập giới tính');
      return;
    }
    if (_birthDateController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập ngày sinh');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse weight
      double? weight;
      if (_weightController.text.trim().isNotEmpty) {
        weight = double.tryParse(_weightController.text.trim());
        if (weight == null) {
          _showErrorSnackBar('Cân nặng không hợp lệ');
          return;
        }
      }

      // Create updated pet
      final updatedPet = Pet(
        id: widget.pet.id,
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        breed: _breedController.text.trim(),
        gender: _genderController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        imageUrl: _imagePath,
        weight: weight,
        weightHistory: widget.pet.weightHistory,
        careHistory: widget.pet.careHistory,
        vaccinationHistory: widget.pet.vaccinationHistory,
        accessoryHistory: widget.pet.accessoryHistory,
        foodHistory: widget.pet.foodHistory,
      );

      // Update pet in service
      final petService = context.read<PetService>();
      petService.updatePet(updatedPet);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật thông tin ${updatedPet.name}'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelEdit() {
    Navigator.pop(context);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}





