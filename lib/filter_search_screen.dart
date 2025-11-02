// lib/filter_search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'pet_service.dart';
import 'pet_detail_screen.dart';
import 'login_screen.dart';
import 'user_profile_screen.dart';
import 'sound_helper.dart';
import 'dart:io';

class FilterSearchScreen extends StatefulWidget {
  final bool showAccountInfo;
  
  const FilterSearchScreen({super.key, this.showAccountInfo = false});

  @override
  State<FilterSearchScreen> createState() => _FilterSearchScreenState();
}

class _FilterSearchScreenState extends State<FilterSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSpecies;
  String? _selectedBreed;
  List<Pet> _filteredPets = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Google Sign-In với Client ID
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '905772912335-slflqvo23plqorc6qti04fgg2ifct2le.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<void> _handleLogout() async {
    try {
      // Đăng xuất khỏi Google nếu đang đăng nhập bằng Google
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }
      
      // Đăng xuất khỏi Firebase
      await _auth.signOut();
      
      // Chuyển đến màn hình đăng nhập
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng xuất: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _filteredPets = context.read<PetService>().pets;
  }

  void _applyFilters() {
    final petService = context.read<PetService>();
    setState(() {
      _filteredPets = petService.filterPets(
        species: _selectedSpecies,
        breed: _selectedBreed,
        searchQuery: _searchController.text,
      );
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSpecies = null;
      _selectedBreed = null;
      _searchController.clear();
      _filteredPets = context.read<PetService>().pets;
    });
  }

  @override
  Widget build(BuildContext context) {
    final petService = context.watch<PetService>();
    
    // Nếu showAccountInfo là true, hiển thị thông tin tài khoản
    if (widget.showAccountInfo) {
      final user = _auth.currentUser;
      
      return Scaffold(
        appBar: AppBar(
          title: Text('account'.tr()),
          backgroundColor: Colors.teal[700],
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar và thông tin cơ bản
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.teal[100],
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Icon(Icons.person, size: 50, color: Colors.teal)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.displayName ?? user?.email?.split('@')[0] ?? 'user'.tr(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user?.email != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          user!.email!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Menu options
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.teal),
                  title: Text('personal_info'.tr()),
                  subtitle: Text('edit_personal_info'.tr()),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    SoundHelper.playClickSound();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Nút đăng xuất
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text('logout'.tr(), style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _handleLogout,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Nếu không phải showAccountInfo, hiển thị màn hình tìm kiếm bình thường
    final availableSpecies = petService.getAvailableSpecies();
    final availableBreeds = petService.getAvailableBreeds();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'search'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Bộ lọc
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
                // Thanh tìm kiếm
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, loài, giống...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
                const SizedBox(height: 16),
                
                // Bộ lọc loài và giống
                Row(
                  children: [
                    // Dropdown loài
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSpecies,
                        decoration: InputDecoration(
                          labelText: 'Loài',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tất cả loài'),
                          ),
                          ...availableSpecies.map((species) => DropdownMenuItem<String>(
                            value: species,
                            child: Text(species),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecies = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Dropdown giống
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBreed,
                        decoration: InputDecoration(
                          labelText: 'Giống',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tất cả giống'),
                          ),
                          ...availableBreeds.map((breed) => DropdownMenuItem<String>(
                            value: breed,
                            child: Text(breed),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedBreed = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Kết quả tìm kiếm
          Expanded(
            child: _filteredPets.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không tìm thấy thú cưng nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Hãy thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPets.length,
                    itemBuilder: (context, index) {
                      final pet = _filteredPets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal[100],
                            child: pet.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.file(
                                      File(pet.imageUrl!),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.pets,
                                          size: 30,
                                          color: Colors.teal[700],
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.pets,
                                    size: 30,
                                    color: Colors.teal[700],
                                  ),
                          ),
                          title: Text(
                            pet.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Loài: ${pet.species}'),
                              Text('Giống: ${pet.breed}'),
                              Text('Giới tính: ${pet.gender}'),
                              if (pet.weight != null)
                                Text('Cân nặng: ${pet.weight!.toStringAsFixed(1)} kg'),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.teal[700],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetDetailScreen(petId: pet.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}





