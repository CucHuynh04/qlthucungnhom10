import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'pet_service.dart';
import 'package:image_picker/image_picker.dart'; // Cần thiết cho chọn ảnh
import 'dart:io'; // Cần thiết cho đối tượng File

// Đã sửa lỗi 'library_private_types_in_public_api' và 'use_super_parameters'
class AddEditPetScreen extends StatefulWidget {
  final bool isEditing; 
  final String? petId; 

  // Constructor đã được sửa: isEditing là required, petId là tùy chọn (nullable)
  const AddEditPetScreen({
    super.key,
    required this.isEditing,
    this.petId,
  });

  @override
  AddEditPetScreenState createState() => AddEditPetScreenState();
}

class AddEditPetScreenState extends State<AddEditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _petGender;
  final List<String> _genders = ['Đực', 'Cái'];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  File? _pickedImage; // Biến tạm lưu File ảnh mới được chọn
  String? _initialImageUrl; // Lưu trữ URL ảnh ban đầu (từ Service)

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu thú cưng hiện tại nếu đang ở chế độ sửa
    if (widget.isEditing && widget.petId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPetData();
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Tải dữ liệu cũ khi chỉnh sửa
  void _loadPetData() {
    final petService = Provider.of<PetService>(context, listen: false);
    final pet = petService.getPetById(widget.petId!);

    if (pet != null) {
      setState(() {
        _nameController.text = pet.name;
        _speciesController.text = pet.species;
        _breedController.text = pet.breed;
        _birthDateController.text = pet.birthDate;
        _petGender = pet.gender;
        _initialImageUrl = pet.imageUrl; // Tải URL ảnh ban đầu
      });
    }
  }

  // Hàm chọn ảnh từ thư viện hoặc chụp mới
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        _initialImageUrl = null; // Xóa URL cũ nếu có ảnh mới
      });
    }
    // Đóng BottomSheet
    Navigator.of(context).pop(); 
  }
  
  // Mở BottomSheet để chọn nguồn ảnh
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('take_photo'.tr()),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('select_from_library'.tr()),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }


  void _savePet() {
    if (_formKey.currentState!.validate()) {
      final petService = Provider.of<PetService>(context, listen: false);

      final petToSave = Pet(
        // Lấy ID cũ nếu sửa, tạo ID mới nếu thêm
        id: widget.isEditing && widget.petId != null ? widget.petId! : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        species: _speciesController.text,
        breed: _breedController.text,
        gender: _petGender!,
        birthDate: _birthDateController.text,
        // LƯU PATH CỦA ẢNH
        imageUrl: _pickedImage?.path ?? _initialImageUrl, 
      );

      if (widget.isEditing) {
        petService.updatePet(petToSave);
      } else {
        petService.addPet(petToSave);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.isEditing ? 'Sửa' : 'Thêm'} thành công hồ sơ: ${_nameController.text}'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _deletePet() {
    if (widget.petId != null) {
      Provider.of<PetService>(context, listen: false).deletePet(widget.petId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa hồ sơ thú cưng!')),
      );
      Navigator.pop(context);
    }
  }

  // Hàm chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Sửa Hồ Sơ ${_nameController.text}' : 'Thêm Thú Cưng Mới',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deletePet, 
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- 1. Ảnh Đại Diện (Đã thêm onTap) ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      // Hiển thị ảnh: ưu tiên _pickedImage, sau đó _initialImageUrl
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (_initialImageUrl != null ? FileImage(File(_initialImageUrl!)) : null), 
                      child: _pickedImage == null && _initialImageUrl == null
                          ? const Icon(Icons.photo_camera, size: 40, color: Colors.white)
                          : null, 
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector( 
                        onTap: _showImageSourceSheet, // Gọi hàm mở BottomSheet
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. Tên Thú Cưng ---
              _buildTextField(
                controller: _nameController,
                label: 'Tên thú cưng',
                hint: 'Nhập tên',
                icon: Icons.badge,
              ),

              // --- 3. Loài ---
              _buildTextField(
                controller: _speciesController,
                label: 'Loài (Ví dụ: Chó, Mèo)',
                hint: 'Nhập loài',
                icon: Icons.auto_awesome,
              ),

              // --- 4. Giống ---
              _buildTextField(
                controller: _breedController,
                label: 'Giống (Ví dụ: Poodle, Scottish Fold)',
                hint: 'Nhập giống',
                icon: Icons.pets,
              ),
              
              // --- 5. Ngày Sinh ---
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  hintText: 'DD/MM/YYYY',
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                readOnly: true, 
                onTap: () => _selectDate(context), 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn ngày sinh';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // --- 6. Giới Tính (Dropdown) ---
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Giới tính',
                  prefixIcon: const Icon(Icons.people_alt, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                initialValue: _petGender, 
                hint: Text('select_gender'.tr()),
                items: _genders.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _petGender = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn giới tính';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 40),
              
              // --- 7. Nút Lưu ---
              ElevatedButton(
                onPressed: _savePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.isEditing ? 'LƯU THAY ĐỔI' : 'THÊM HỒ SƠ',
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget helper để tái sử dụng TextFormField
  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }
          return null;
        },
      ),
    );
  }
}




