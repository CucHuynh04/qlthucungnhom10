import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'pet_service.dart';
import 'edit_pet_screen.dart';
import 'dart:io';

class PetDetailScreen extends StatelessWidget {
  final String petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetService>(
      builder: (context, petService, child) {
        final pet = petService.pets.firstWhere((p) => p.id == petId);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(pet.name),
            backgroundColor: Colors.teal[700],
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditPetDialog(context, pet),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context, pet),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet info card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Pet image with add button
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.teal[100],
                              child: pet.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: Image.file(
                                        File(pet.imageUrl!),
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
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _pickImage(context, pet),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.teal[700],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Pet basic info
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${pet.species} - ${pet.breed}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Pet details
                        _buildInfoRow('Giới tính', pet.gender, Icons.pets),
                        _buildInfoRow('Ngày sinh', pet.birthDate, Icons.cake),
                        if (pet.weight != null)
                          _buildInfoRow('Cân nặng', '${pet.weight!.toStringAsFixed(1)} kg', Icons.monitor_weight),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Statistics section
                const Text(
                  'Thống kê',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Statistics cards
                _buildStatCard(context, 'Cân nặng', '${pet.weightHistory.length} lần ghi nhận', Icons.monitor_weight, Colors.blue, pet),
                const SizedBox(height: 12),
                _buildStatCard(context, 'Chăm sóc', '${pet.careHistory.length} lần chăm sóc', Icons.healing, Colors.green, pet),
                const SizedBox(height: 12),
                _buildStatCard(context, 'Tiêm chủng', '${pet.vaccinationHistory.length} lần tiêm', Icons.medical_services, Colors.red, pet),
                const SizedBox(height: 12),
                _buildStatCard(context, 'Phụ kiện', '${pet.accessoryHistory.length} phụ kiện', Icons.shopping_bag, Colors.orange, pet),
                const SizedBox(height: 12),
                _buildStatCard(context, 'Thức ăn', '${pet.foodHistory.length} loại thức ăn', Icons.restaurant, Colors.purple, pet),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal[700], size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String subtitle, IconData icon, Color color, Pet pet) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDetailDialog(context, title, subtitle, icon, color, pet),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, String title, String subtitle, IconData icon, Color color, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _buildDetailContent(title, pet),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(String title, Pet pet) {
    switch (title) {
      case 'Cân nặng':
        return _buildWeightDetail(pet);
      case 'Chăm sóc':
        return _buildCareDetail(pet);
      case 'Tiêm chủng':
        return _buildVaccinationDetail(pet);
      case 'Phụ kiện':
        return _buildAccessoryDetail(pet);
      case 'Thức ăn':
        return _buildFoodDetail(pet);
      default:
        return Text('no_data_available'.tr());
    }
  }

  Widget _buildWeightDetail(Pet pet) {
    if (pet.weightHistory.isEmpty) {
      return Text('no_weight_data'.tr());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Lịch sử cân nặng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...pet.weightHistory.map((record) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.monitor_weight, color: Colors.blue),
            title: Text('${record.weight.toStringAsFixed(1)} kg'),
            subtitle: Text('${record.date.day}/${record.date.month}/${record.date.year}'),
            trailing: record.notes != null ? const Icon(Icons.note) : null,
          ),
        )),
      ],
    );
  }

  Widget _buildCareDetail(Pet pet) {
    if (pet.careHistory.isEmpty) {
      return Text('no_data_available'.tr());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Lịch sử chăm sóc',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...pet.careHistory.map((record) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.healing, color: Colors.green),
            title: Text(record.type),
            subtitle: Text('${record.date.day}/${record.date.month}/${record.date.year}'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (record.cost != null)
                  Text('${record.cost!.toStringAsFixed(0)} VNĐ', 
                       style: const TextStyle(fontWeight: FontWeight.bold)),
                if (record.notes != null) const Icon(Icons.note),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildVaccinationDetail(Pet pet) {
    if (pet.vaccinationHistory.isEmpty) {
      return Text('no_data_available'.tr());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Lịch sử tiêm chủng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...pet.vaccinationHistory.map((record) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.medical_services, color: Colors.red),
            title: Text(record.vaccineName),
            subtitle: Text('${record.date.day}/${record.date.month}/${record.date.year}'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (record.nextDueDate != null)
                  Text('Tiếp theo: ${record.nextDueDate!.day}/${record.nextDueDate!.month}/${record.nextDueDate!.year}',
                       style: const TextStyle(fontSize: 12)),
                if (record.notes != null) const Icon(Icons.note),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildAccessoryDetail(Pet pet) {
    if (pet.accessoryHistory.isEmpty) {
      return Text('no_data_available'.tr());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Lịch sử phụ kiện',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...pet.accessoryHistory.map((record) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.orange),
            title: Text(record.name),
            subtitle: Text('${record.type} - ${record.date.day}/${record.date.month}/${record.date.year}'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (record.cost != null)
                  Text('${record.cost!.toStringAsFixed(0)} VNĐ', 
                       style: const TextStyle(fontWeight: FontWeight.bold)),
                if (record.notes != null) const Icon(Icons.note),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildFoodDetail(Pet pet) {
    if (pet.foodHistory.isEmpty) {
      return Text('no_data_available'.tr());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Lịch sử thức ăn',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...pet.foodHistory.map((record) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.purple),
            title: Text(record.name),
            subtitle: Text('${record.type} - ${record.date.day}/${record.date.month}/${record.date.year}'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (record.cost != null)
                  Text('${record.cost!.toStringAsFixed(0)} VNĐ', 
                       style: const TextStyle(fontWeight: FontWeight.bold)),
                if (record.notes != null) const Icon(Icons.note),
              ],
            ),
          ),
        )),
      ],
    );
  }

  void _pickImage(BuildContext context, Pet pet) async {
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
                title: Text('take_photo'.tr()),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('select_from_gallery'.tr()),
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
          // Update pet with new image
          final updatedPet = Pet(
            id: pet.id,
            name: pet.name,
            species: pet.species,
            breed: pet.breed,
            gender: pet.gender,
            birthDate: pet.birthDate,
            imageUrl: image.path,
            weight: pet.weight,
            weightHistory: pet.weightHistory,
            careHistory: pet.careHistory,
            vaccinationHistory: pet.vaccinationHistory,
            accessoryHistory: pet.accessoryHistory,
            foodHistory: pet.foodHistory,
          );

          final petService = context.read<PetService>();
          petService.updatePet(updatedPet);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật ảnh thành công'),
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

  void _showEditPetDialog(BuildContext context, Pet pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPetScreen(pet: pet),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete'.tr()),
        content: Text('Bạn có chắc chắn muốn xóa thú cưng "${pet.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final petService = context.read<PetService>();
              petService.deletePet(pet.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa thú cưng "${pet.name}"')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}




