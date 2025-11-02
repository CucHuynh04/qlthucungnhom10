// lib/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'message_bubble.dart';
import 'messages.dart';
import 'pet_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  String _enteredMessage = '';
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    
    if (_enteredMessage.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('chat').add({
        'text': _enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user!.uid,
        'imageUrl': null,
      });
      _controller.clear();
      setState(() {
        _enteredMessage = '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('send_message_error'.tr() + ' $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final Reference ref = FirebaseStorage.instance.ref().child('chat_images/$fileName');

      await ref.putFile(File(image.path));
      final String imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('chat').add({
        'text': _enteredMessage.trim().isEmpty ? '' : _enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user!.uid,
        'imageUrl': imageUrl,
      });

      if (_enteredMessage.isNotEmpty) {
        _controller.clear();
        setState(() {
          _enteredMessage = '';
        });
      }

      setState(() {
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('load_image_error'.tr() + ' $e')),
        );
      }
    }
  }

  Future<void> _sharePetProfile() async {
    final petService = Provider.of<PetService>(context, listen: false);
    final pets = petService.pets;

    if (pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_pets_yet'.tr())),
      );
      return;
    }

    // Show dialog to select pet
    final selectedPet = await showDialog<Pet>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('select_pet_to_share'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return ListTile(
                leading: pet.imageUrl != null
                    ? CircleAvatar(
                        backgroundImage: FileImage(File(pet.imageUrl!)),
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.pets),
                      ),
                title: Text(pet.name),
                subtitle: Text('${pet.species} - ${pet.breed}'),
                onTap: () => Navigator.pop(context, pet),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
        ],
      ),
    );

    if (selectedPet != null) {
      // Create message with pet info - đầy đủ thông tin
      final StringBuffer buffer = StringBuffer();
      
      buffer.writeln('${'share_pet_info'.tr()}: ${selectedPet.name}');
      buffer.writeln('');
      
      // Thông tin cơ bản
      buffer.writeln('📋 THÔNG TIN CƠ BẢN');
      buffer.writeln('📝 ${'pet_name_label'.tr()} ${selectedPet.name}');
      buffer.writeln('🏷️ ${'species_label_full'.tr()} ${selectedPet.species}');
      buffer.writeln('🐕 ${'breed_label_full'.tr()} ${selectedPet.breed}');
      buffer.writeln('👤 ${'gender'.tr()}: ${selectedPet.gender}');
      buffer.writeln('🎂 ${'birth_date'.tr()}: ${selectedPet.birthDate}');
      
      if (selectedPet.weight != null) {
        buffer.writeln('⚖️ ${'weight'.tr()}: ${selectedPet.weight!.toStringAsFixed(1)} kg');
      }
      
      // Lịch sử cân nặng
      if (selectedPet.weightHistory.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('📊 ${'weight_history'.tr()} (${selectedPet.weightHistory.length} ${'times'.tr()}):');
        final recentWeights = selectedPet.weightHistory.take(5).toList();
        for (var weight in recentWeights) {
          buffer.writeln('  • ${weight.date.day}/${weight.date.month}/${weight.date.year}: ${weight.weight} kg');
        }
      }
      
      // Lịch sử chăm sóc
      if (selectedPet.careHistory.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('💚 ${'care_history'.tr()} (${selectedPet.careHistory.length} ${'times'.tr()}):');
        final recentCares = selectedPet.careHistory.take(5).toList();
        for (var care in recentCares) {
          buffer.writeln('  • ${care.date.day}/${care.date.month}/${care.date.year}: ${care.type} - ${care.cost != null ? "${care.cost!.toStringAsFixed(0)} VNĐ" : ""}');
        }
      }
      
      // Lịch sử tiêm chủng (quan trọng!)
      if (selectedPet.vaccinationHistory.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('💉 ${'vaccination_history'.tr()} (${selectedPet.vaccinationHistory.length} ${'times'.tr()}):');
        for (var vac in selectedPet.vaccinationHistory) {
          buffer.writeln('  • ${vac.date.day}/${vac.date.month}/${vac.date.year}: ${vac.vaccineName}');
          if (vac.nextDueDate != null) {
            buffer.writeln('    Mũi tiếp theo: ${vac.nextDueDate!.day}/${vac.nextDueDate!.month}/${vac.nextDueDate!.year}');
          }
        }
      }
      
      // Lịch sử phụ kiện
      if (selectedPet.accessoryHistory.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('🛍️ ${'accessory_history'.tr()} (${selectedPet.accessoryHistory.length} ${'unit_piece'.tr()}):');
        final recentAccessories = selectedPet.accessoryHistory.take(5).toList();
        for (var acc in recentAccessories) {
          buffer.writeln('  • ${acc.date.day}/${acc.date.month}/${acc.date.year}: ${acc.name} (${acc.type})');
        }
      }
      
      // Lịch sử thức ăn
      if (selectedPet.foodHistory.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('🍖 ${'food_history'.tr()} (${selectedPet.foodHistory.length} ${'times'.tr()}):');
        final recentFoods = selectedPet.foodHistory.take(5).toList();
        for (var food in recentFoods) {
          buffer.writeln('  • ${food.date.day}/${food.date.month}/${food.date.year}: ${food.name} (${food.type})');
        }
      }

      try {
        final user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance.collection('chat').add({
          'text': buffer.toString(),
          'createdAt': Timestamp.now(),
          'userId': user!.uid,
          'imageUrl': null,
          'petId': selectedPet.id,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('pet_shared'.tr() + ' ${selectedPet.name}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('send_message_error'.tr() + ' $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chat_title'.tr(), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Text(
                'ID: ${FirebaseAuth.instance.currentUser?.uid.substring(0, 8) ?? ""}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Text('logout'.tr()),
              ),
            ],
            onSelected: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Messages(),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Row(
                children: [
                  // Nút chọn ảnh
                  IconButton(
                    icon: _isUploading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.image, color: Colors.teal),
                    onPressed: _isUploading ? null : _pickAndUploadImage,
                  ),
                  const SizedBox(width: 5),
                  // Nút chia sẻ hồ sơ thú cưng
                  IconButton(
                    icon: const Icon(Icons.pets, color: Colors.teal),
                    onPressed: _sharePetProfile,
                    tooltip: 'share_pet_profile'.tr(),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'enter_message'.tr(),
                        labelStyle: TextStyle(color: Colors.teal[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.teal[700]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        fillColor: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[800] 
                            : Colors.grey[50],
                        filled: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _enteredMessage = value;
                        });
                      },
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: _enteredMessage.trim().isEmpty ? Colors.grey : Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}





