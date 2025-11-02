// lib/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sound_helper.dart';
import 'pet_profile_screen.dart'; 
import 'schedule_screen.dart';    
import 'care_log_screen.dart';    
import 'gallery_screen.dart';
import 'filter_search_screen.dart';
import 'charts_stats_screen.dart';
import 'export_share_screen.dart';
import 'add_data_screen.dart';
import 'food_inventory_screen.dart';
import 'common_app_bar.dart';
import 'notification_service.dart';
import 'pet_service.dart';     
import 'auth_wrapper.dart';
import 'chat_screen.dart';
import 'background_music_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'locale_service.dart';
import 'theme_service.dart';
import 'chatbot_screen.dart';     
import 'package:image_picker/image_picker.dart';
import 'dart:io';     

class HomePage extends StatefulWidget {
  const HomePage({super.key}); 
  @override
  HomePageState createState() => HomePageState(); 
}

class HomePageState extends State<HomePage> { 
  int _currentIndex = 0; 
  bool _galleryPetSelected = false; // Track xem GalleryScreen đã chọn pet chưa
  String? _gallerySelectedPetId; // Lưu pet ID đang được chọn trong GalleryScreen
  String? _foodInventorySelectedPetId; // Lưu pet ID đang được chọn trong FoodInventoryScreen
  String? _careLogSelectedPetId; // Lưu pet ID đang được chọn trong CareLogScreen
  
  // KHÔNG DÙNG const CHO CÁC WIDGET BÊN TRONG LIST để tránh lỗi
  List<Widget> get _screens => [
    PetProfileScreen(),     // Hồ Sơ
    AddDataScreen(),        // Thêm Dữ Liệu
    FoodInventoryScreen(
      onPetIdChanged: (petId) {
        setState(() {
          _foodInventorySelectedPetId = petId;
        });
      },
    ),  // Kho Thức Ăn
    ScheduleScreen(),       // Lịch Hẹn
    ChartsStatsScreen(),    // Biểu Đồ & Thống Kê
    CareLogScreen(
      onPetIdChanged: (petId) {
        setState(() {
          _careLogSelectedPetId = petId;
        });
      },
    ),        // Nhật Ký
    GalleryScreen(
      onPetSelectedChanged: (selected) {
        setState(() {
          _galleryPetSelected = selected;
        });
      },
      onPetIdChanged: (petId) {
        setState(() {
          _gallerySelectedPetId = petId;
        });
      },
    ),        // Bộ Sưu Tập
    ExportShareScreen(),    // Xuất & Chia Sẻ
    FilterSearchScreen(showAccountInfo: true),   // Tài khoản
  ];
  


  @override
  void initState() {
    super.initState();
    // Kiểm tra thông báo khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = context.read<NotificationService>();
      final petService = context.read<PetService>();
      notificationService.checkScheduleNotifications(petService);
      
      // Auto play nhạc khi vào HomePage (user đã có interaction - đăng nhập)
      final musicService = context.read<BackgroundMusicService>();
      if (musicService.isEnabled && !musicService.isPlaying) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          try {
            print('Auto-playing music after login (user interaction detected)...');
            await musicService.play();
          } catch (e) {
            print('Error auto-playing music after login: $e');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PetService>(
      builder: (context, petService, child) {
        // Cập nhật thông báo khi PetService thay đổi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final notificationService = context.read<NotificationService>();
          notificationService.checkScheduleNotifications(petService);
        });

        return Scaffold(
          extendBody: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: _buildDrawer(),
          appBar: CommonAppBar(
            title: _getAppBarTitle(context),
            showNotificationBell: true,
            actions: _getAppBarActions(context),
          ),
          body: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child: _screens[_currentIndex],
            ),
          ),
          floatingActionButton: Stack(
            clipBehavior: Clip.none,
            children: [
              // Nút AI Chatbot - hiển thị ở tất cả màn hình
              Positioned(
                left: 20,
                bottom: 71, // Khoảng cách với nút chat 14 pixel (1 + 56 + 14 = 71)
                child: FloatingActionButton(
                  heroTag: "chatbot_button",
                  onPressed: () {
                    SoundHelper.playClickSound();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatbotScreen()),
                    );
                  },
                  backgroundColor: Colors.purple,
                  child: const Icon(Icons.smart_toy, color: Colors.white),
                ),
              ),
              // Nút chat - hiển thị ở tất cả màn hình
              Positioned(
                left: 20,
                bottom: 1, // Cách bottom navigation bar 1 pixel
                child: FloatingActionButton(
                  heroTag: "chat_button",
                  onPressed: () {
                    SoundHelper.playClickSound();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                  backgroundColor: Colors.teal,
                  child: const Icon(Icons.chat, color: Colors.white),
                ),
              ),
              // Nút thêm - thay đổi theo màn hình hiện tại
              if (_currentIndex == 0)
                // Màn hình "Hồ Sơ" - hiển thị nút "Thêm Thú Cưng" với icon dấu cộng
                // Đặt cùng vị trí bottom với nút chat để cân đối
                Positioned(
                  right: -10,
                  bottom: 1, // Cách bottom navigation bar 1 pixel
                  child: FloatingActionButton(
                    heroTag: "add_pet_button",
                    onPressed: () {
                      SoundHelper.playClickSound();
                      _showAddPetDialog(context);
                    },
                    backgroundColor: Colors.teal,
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                      .animate()
                      
                      )
              else if (_currentIndex == 1)
                // Màn hình "Thêm Dữ Liệu" - không hiển thị nút (đã có trong AddDataScreen)
                const SizedBox.shrink()
              else if (_currentIndex == 2 && _foodInventorySelectedPetId != null)
                // Màn hình "Kho Thức Ăn" - chỉ hiển thị nút khi đã chọn thú cưng
                Positioned(
                  right: -10,
                  bottom: 1, // Cách bottom navigation bar 1 pixel
                  child: FloatingActionButton(
                    heroTag: "add_food_button_home",
                    onPressed: () {
                      SoundHelper.playClickSound();
                      _showAddFoodDialogFromHome(context);
                    },
                    backgroundColor: Colors.teal[700],
                    child: const Icon(Icons.add, color: Colors.white),
                  ).animate(),
                )
              else if (_currentIndex == 3)
                // Màn hình "Lịch Hẹn" - hiển thị nút "Thêm Lịch Hẹn"
                Positioned(
                  right: -10,
                  bottom: 1, // Cách bottom navigation bar 1 pixel
                  child: FloatingActionButton(
                    heroTag: "add_schedule_button_home",
                    onPressed: () {
                      SoundHelper.playClickSound();
                      _showAddScheduleDialogFromHome(context);
                    },
                    backgroundColor: Colors.teal[700],
                    child: const Icon(Icons.add, color: Colors.white),
                  ).animate(),
                )
              else if (_currentIndex == 5 && _careLogSelectedPetId != null)
                // Màn hình "Nhật Ký Chăm Sóc" - chỉ hiển thị nút khi đã chọn thú cưng
                Positioned(
                  right: -10,
                  bottom: 1, // Cách bottom navigation bar 1 pixel
                  child: FloatingActionButton(
                    heroTag: "add_care_log_button_home",
                    onPressed: () {
                      SoundHelper.playClickSound();
                      _showAddCareLogDialogFromHome(context);
                    },
                    backgroundColor: Colors.teal[700],
                    child: const Icon(Icons.add, color: Colors.white),
                  ).animate(),
                )
              else if (_currentIndex == 6 && _galleryPetSelected)
                // Màn hình "Bộ Sưu Tập" - chỉ hiển thị nút khi đã chọn thú cưng
                Positioned(
                  right: -10,
                  bottom: 1, // Cách bottom navigation bar 1 pixel
                  child: FloatingActionButton(
                    heroTag: "add_gallery_button_home",
                    onPressed: () {
                      SoundHelper.playClickSound();
                      _showAddGalleryDialogFromHome(context);
                    },
                    backgroundColor: Colors.teal[700],
                    child: const Icon(Icons.add, color: Colors.white),
                  ).animate(),
                ),
            ],
          ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
        onTap: (index) {
          SoundHelper.playClickSound();
          setState(() {
            _currentIndex = index; 
            // Reset gallery pet selection khi chuyển tab
            if (index != 6) {
              _galleryPetSelected = false;
              _gallerySelectedPetId = null;
            }
          });
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Colors.teal[700],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.pets),
            label: 'profile'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: 'add_data'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fastfood),
            label: 'food_inventory'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: 'schedule'.tr(),
          ),
        ],
      )
          .animate()
          );
      },
    );
  }

  String _getAppBarTitle(BuildContext context) {
    switch (_currentIndex) {
      case 0: return 'my_pets'.tr();
      case 1: return 'add_data'.tr();
      case 2: return 'food_inventory'.tr();
      case 3: return 'schedule'.tr();
      case 4: return 'statistics'.tr();
      case 5: return 'care_log'.tr();
      case 6: return 'gallery'.tr();
      case 7: return 'export_share'.tr();
      case 8: return 'account'.tr();
      default: return 'app_title'.tr();
    }
  }

  void _navigateToScreen(int index) {
    // Nếu index trong khoảng bottom nav (0-3), chỉ cần set
    if (index <= 3) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      // Nếu index > 3, là màn hình trong drawer, mở drawer
      Scaffold.of(context).openDrawer();
    }
  }

  void _showAddPetDialog(BuildContext context) {
    final nameController = TextEditingController();
    final speciesController = TextEditingController();
    final breedController = TextEditingController();
    final genderController = TextEditingController();
    final birthDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('add_pet'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'pet_name'.tr(),
                  hintText: 'pet_name'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: speciesController,
                decoration: InputDecoration(
                  labelText: 'species'.tr(),
                  hintText: 'species'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: breedController,
                decoration: InputDecoration(
                  labelText: 'breed'.tr(),
                  hintText: 'breed'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: genderController,
                decoration: InputDecoration(
                  labelText: 'gender'.tr(),
                  hintText: '${'male'.tr()}/${'female'.tr()}',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: birthDateController,
                decoration: InputDecoration(
                  labelText: '${'birth_date'.tr()} (${'date_format'.tr()})',
                  hintText: '01/01/2020',
                ),
              ),
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
              if (nameController.text.isNotEmpty) {
                final petService = context.read<PetService>();
                final newPet = Pet(
                  id: '', // ID sẽ được tự động tạo trong addPet
                  name: nameController.text,
                  species: speciesController.text,
                  breed: breedController.text,
                  gender: genderController.text,
                  birthDate: birthDateController.text,
                  imageUrl: null,
                  weight: null,
                );
                petService.addPet(newPet);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${'Đã thêm thú cưng'.tr()}: ${nameController.text}'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tên thú cưng'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text('add'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.teal,
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 36,
                )
                    .animate()
                    ,
                const SizedBox(height: 8),
                Text(
                  'pet_manager'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    .animate()
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.teal),
            title: Text('statistics'.tr()),
            onTap: () {
              SoundHelper.playClickSound();
              setState(() {
                _currentIndex = 4;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.book, color: Colors.teal),
            title: Text('care_log'.tr()),
            onTap: () {
              SoundHelper.playClickSound();
              setState(() {
                _currentIndex = 5;
              });
              Navigator.pop(context);
            },
          )
              .animate(), ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.teal),
            title: Text('gallery'.tr()),
            onTap: () {
              SoundHelper.playClickSound();
              setState(() {
                _currentIndex = 6;
              });
              Navigator.pop(context);
            },
          )
              .animate(), ListTile(
            leading: const Icon(Icons.share, color: Colors.teal),
            title: Text('export_share'.tr()),
            onTap: () {
              SoundHelper.playClickSound();
              setState(() {
                _currentIndex = 7;
              });
              Navigator.pop(context);
            },
          )
              .animate(), const Divider(),
          Consumer<LocaleService>(
            builder: (context, localeService, child) {
              return ExpansionTile(
                leading: const Icon(Icons.language, color: Colors.teal),
                title: Text('language'.tr()),
                trailing: Text(
                  localeService.locale.languageCode.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  RadioListTile<String>(
                    title: Text('vietnamese'.tr()),
                    value: 'vi',
                    groupValue: localeService.locale.languageCode,
                    onChanged: (String? value) async {
                      if (value != null) {
                        await localeService.setLocale(const Locale('vi'));
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('english'.tr()),
                    value: 'en',
                    groupValue: localeService.locale.languageCode,
                    onChanged: (String? value) async {
                      if (value != null) {
                        await localeService.setLocale(const Locale('en'));
                      }
                    },
                  ),
                ],
              );
            },
          ),
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return SwitchListTile(
                secondary: Icon(
                  themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.teal,
                ),
                title: Text('dark_mode'.tr()),
                value: themeService.isDarkMode,
                onChanged: (bool value) async {
                  await themeService.toggleTheme();
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.music_note, color: Colors.teal),
            title: Text('background_music'.tr()),
            subtitle: Consumer<BackgroundMusicService>(
              builder: (context, music, child) {
                if (music.isEnabled) {
                  return Text('${'volume'.tr()}: ${(music.volume * 100).toInt()}%');
                }
                return Text('disabled'.tr());
              },
            ),
            onTap: () {
              SoundHelper.playClickSound();
              Navigator.pop(context);
              _showMusicDialog(context);
            },
          )
              .animate(), const Divider(),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: Text('account'.tr()),
            onTap: () {
              SoundHelper.playClickSound();
              setState(() {
                _currentIndex = 8;
              });
              Navigator.pop(context);
            },
          )
              .animate(), ],
      ),
    );
  }

  void _showMusicDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final musicService = context.watch<BackgroundMusicService>();
          
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Âm lượng nhạc nền',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
            
                // Bật/tắt nhạc
                SwitchListTile(
                  title: const Text('Nhạc nền'),
                  subtitle: Text(musicService.isEnabled ? 'Đang bật' : 'Đang tắt'),
                  value: musicService.isEnabled,
                  onChanged: (value) async {
                    print('Switch toggled: $value');
                    try {
                      await musicService.setEnabled(value);
                      setState(() {}); // Force rebuild to show updated state
                      print('Music service updated successfully');
                    } catch (e) {
                      print('Error toggling music: $e');
                      // Show error to user
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: $e')),
                        );
                      }
                    }
                  },
                ),
                
                if (musicService.isEnabled) ...[
                  const Divider(),
                  
                  // Điều chỉnh âm lượng
                  Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volume_down, size: 20),
                      Expanded(
                        child: Slider(
                          value: musicService.volume,
                          onChanged: (value) {
                            musicService.volume = value;
                          },
                          min: 0.0,
                          max: 1.0,
                        ),
                      ),
                      const Icon(Icons.volume_up, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Âm lượng: ${(musicService.volume * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    ),
                  ],
                ),
                const Divider(),
                
                // Chọn track
                if (musicService.tracks.length > 1) ...[
                  const Text(
                  'Chọn nhạc nền',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: musicService.tracks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final track = entry.value.split('/').last;
                    return ChoiceChip(
                      label: Text(track),
                      selected: index == musicService.currentTrackIndex,
                      onSelected: (_) async {
                        await musicService.selectTrack(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã chọn: $track')),
                        );
                      },
                    );
                  }).toList(),
                ),
                  const SizedBox(height: 20),
                ],
                
                // Nút điều khiển
                if (musicService.tracks.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: () async {
                          await musicService.previousTrack();
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          musicService.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 48,
                        ),
                        onPressed: () async {
                          if (musicService.isPlaying) {
                            await musicService.pause();
                          } else {
                            await musicService.play();
                          }
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: () async {
                          await musicService.nextTrack();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
              ],
            ],
          ),
          );
        },
      ),
    );
  }

  List<Widget>? _getAppBarActions(BuildContext context) {
    switch (_currentIndex) {
      case 0: // Hồ Sơ
        return [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'search'.tr(),
            onPressed: () {
              SoundHelper.playClickSound();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilterSearchScreen(),
                ),
              );
            },
          ),
        ];
      case 2: // Lịch Hẹn
        return [
          PopupMenuButton<String>(
            onSelected: (value) {
              SoundHelper.playClickSound();
              // Cần truyền callback để update state trong ScheduleScreen
              // Tạm thời để trống, sẽ sửa sau
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: 'all', child: Text('all'.tr())),
                PopupMenuItem(value: 'care', child: Text('care'.tr())),
                PopupMenuItem(value: 'vaccination', child: Text('vaccination'.tr())),
                PopupMenuItem(value: 'play', child: Text('play_time'.tr())),
              ];
            },
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ];
      case 4: // Nhật Ký
        return [
          PopupMenuButton<String>(
            onSelected: (value) {
              SoundHelper.playClickSound();
              // Cần truyền callback để update state trong CareLogScreen
              // Tạm thời để trống, sẽ sửa sau
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: 'all', child: Text('all'.tr())),
                PopupMenuItem(value: 'weight', child: Text('weight'.tr())),
                PopupMenuItem(value: 'care', child: Text('care'.tr())),
                PopupMenuItem(value: 'vaccination', child: Text('vaccination'.tr())),
                PopupMenuItem(value: 'accessory', child: Text('accessories'.tr())),
                PopupMenuItem(value: 'food', child: Text('food'.tr())),
              ];
            },
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ];
      case 5: // Bộ Sưu Tập
        return [
          PopupMenuButton<String>(
            onSelected: (value) {
              SoundHelper.playClickSound();
              // Cần truyền callback để update state trong GalleryScreen
              // Tạm thời để trống, sẽ sửa sau
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: 'all', child: Text('all'.tr())),
                PopupMenuItem(value: 'photos', child: Text('photos'.tr())),
                PopupMenuItem(value: 'videos', child: Text('videos'.tr())),
              ];
            },
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.checklist, color: Colors.white),
            onPressed: () {
              SoundHelper.playClickSound();
              // Cần truyền callback để enter selection mode trong GalleryScreen
              // Tạm thời để trống, sẽ sửa sau
            },
          ),
        ];
      default:
        return null;
    }
  }

  void _showAddScheduleDialogFromHome(BuildContext context) {
    final petService = context.read<PetService>();
    String? selectedType;
    String? selectedPetId;
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    TimeOfDay? selectedTime = TimeOfDay.now();
    DateTime selectedDate = DateTime.now(); // Sẽ cho phép chọn lại trong dialog

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('add_schedule'.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'schedule_type'.tr()),
                    items: [
                      DropdownMenuItem(value: 'care', child: Text('routine_checkup'.tr())),
                      DropdownMenuItem(value: 'vaccination', child: Text('vaccination'.tr())),
                      DropdownMenuItem(value: 'play', child: Text('play_time'.tr())),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'pet'.tr()),
                    items: petService.pets.map((pet) => DropdownMenuItem(
                      value: pet.id,
                      child: Text(pet.name),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPetId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề',
                      hintText: 'Để trống để tự động tạo tiêu đề',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Chọn ngày
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 12),
                          Text(
                            selectedTime != null 
                                ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                : 'Chọn thời gian',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(labelText: 'notes'.tr()),
                    maxLines: 2,
                  ),
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
                  if (selectedType == null || selectedPetId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('please_select_pet'.tr())),
                    );
                    return;
                  }

                  final pet = petService.getPetById(selectedPetId!);
                  if (pet != null) {
                    final scheduleDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );

                    String finalTitle = titleController.text.trim();
                    if (finalTitle.isEmpty) {
                      String typeName = '';
                      switch (selectedType) {
                        case 'care':
                          typeName = 'khám định kỳ';
                          break;
                        case 'vaccination':
                          typeName = 'tiêm chủng';
                          break;
                        case 'play':
                          typeName = 'đi chơi';
                          break;
                      }
                      finalTitle = '${pet.name} $typeName';
                    }

                    petService.addSchedule(
                      selectedPetId!,
                      finalTitle,
                      selectedType!,
                      scheduleDateTime,
                      time: '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('export_success'.tr())),
                    );
                  }
                },
                child: Text('add'.tr()),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddCareLogDialogFromHome(BuildContext context) {
    final petService = context.read<PetService>();
    
    // Kiểm tra xem đã chọn pet chưa
    if (_careLogSelectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_select_pet'.tr())),
      );
      return;
    }
    
    // Tạo dialog tương tự như trong CareLogScreen
    String? selectedLogType;
    final notesController = TextEditingController();
    final valueController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
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
                    TextField(
                      controller: valueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'weight_kg'.tr(),
                        hintText: 'Nhập số (ví dụ: 5.2)',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (selectedLogType == 'care') ...[
                    TextField(
                      controller: valueController,
                      decoration: InputDecoration(
                        labelText: 'care_type'.tr(),
                        hintText: 'Nhập loại chăm sóc',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (selectedLogType == 'vaccination') ...[
                    TextField(
                      controller: valueController,
                      decoration: InputDecoration(
                        labelText: 'vaccine_name'.tr(),
                        hintText: 'Nhập tên vaccine',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (selectedLogType == 'accessory') ...[
                    TextField(
                      controller: valueController,
                      decoration: InputDecoration(
                        labelText: 'accessory_name'.tr(),
                        hintText: 'Nhập tên phụ kiện',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (selectedLogType == 'food') ...[
                    TextField(
                      controller: valueController,
                      decoration: InputDecoration(
                        labelText: 'food_name'.tr(),
                        hintText: 'Nhập tên thức ăn',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'log_note'.tr(),
                      hintText: 'Ghi chú (tùy chọn)',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
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

                  // Kiểm tra validation
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
                        _careLogSelectedPetId!,
                        weight,
                        notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      );
                      break;
                    case 'care':
                      petService.addCareRecord(
                        _careLogSelectedPetId!,
                        valueController.text.trim(),
                        null,
                        notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      );
                      break;
                    case 'vaccination':
                      petService.addVaccinationRecord(
                        _careLogSelectedPetId!,
                        valueController.text.trim(),
                        null,
                        notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      );
                      break;
                    case 'accessory':
                      petService.addAccessoryRecord(
                        _careLogSelectedPetId!,
                        valueController.text.trim(),
                        'Phụ kiện',
                        null,
                        notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      );
                      break;
                    case 'food':
                      petService.addFoodRecord(
                        _careLogSelectedPetId!,
                        valueController.text.trim(),
                        'Thức ăn',
                        null,
                        notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      );
                      break;
                  }

                  Navigator.pop(dialogContext);
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

  void _showAddGalleryDialogFromHome(BuildContext context) {
    final petService = context.read<PetService>();
    if (petService.pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_select_pet'.tr())),
      );
      return;
    }

    // Nếu đã chọn pet trong GalleryScreen, dùng pet đó
    String? selectedPetId = _gallerySelectedPetId;
    final ImagePicker _picker = ImagePicker();

    // Nếu chưa có pet nào được chọn, hiển thị dialog chọn pet
    if (selectedPetId == null) {
      if (petService.pets.length > 1) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('pet'.tr()),
            content: DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'pet'.tr()),
              items: petService.pets.map((pet) => DropdownMenuItem(
                value: pet.id,
                child: Text(pet.name),
              )).toList(),
              onChanged: (value) {
                selectedPetId = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedPetId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('please_select_pet'.tr())),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  _showMediaOptionsDialog(context, petService, selectedPetId!, _picker);
                },
                child: Text('add'.tr()),
              ),
            ],
          ),
        );
      } else {
        // Nếu chỉ có 1 pet, dùng luôn
        selectedPetId = petService.pets.first.id;
        _showMediaOptionsDialog(context, petService, selectedPetId, _picker);
      }
    } else {
      // Đã có pet được chọn, hiển thị dialog chọn media ngay
      _showMediaOptionsDialog(context, petService, selectedPetId, _picker);
    }
  }

  void _showAddFoodDialogFromHome(BuildContext context) {
    final petService = context.read<PetService>();
    if (petService.pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_select_pet'.tr())),
      );
      return;
    }

    // Sử dụng pet đang được chọn trong FoodInventoryScreen
    String? selectedPetId = _foodInventorySelectedPetId;
    
    // Nếu chưa có pet nào được chọn, chọn pet đầu tiên hoặc hiển thị dialog chọn pet
    if (selectedPetId == null) {
      if (petService.pets.length > 1) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('pet'.tr()),
            content: DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'pet'.tr()),
              items: petService.pets.map((pet) => DropdownMenuItem(
                value: pet.id,
                child: Text(pet.name),
              )).toList(),
              onChanged: (value) {
                selectedPetId = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedPetId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('please_select_pet'.tr())),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  _showAddFoodDialog(context, petService, selectedPetId!);
                },
                child: Text('add'.tr()),
              ),
            ],
          ),
        );
      } else {
        // Nếu chỉ có 1 pet, dùng luôn
        selectedPetId = petService.pets.first.id;
        _showAddFoodDialog(context, petService, selectedPetId);
      }
    } else {
      // Đã có pet được chọn, hiển thị dialog thêm thức ăn ngay
      _showAddFoodDialog(context, petService, selectedPetId);
    }
  }

  void _showAddFoodDialog(BuildContext context, PetService petService, String petId) {
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
          title: Text('add_food'.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'food_name'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: 'food_type'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.teal),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Chọn ngày mua',
                          style: TextStyle(
                            color: selectedDate != null ? Colors.black : Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'notes_optional'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
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

                petService.addFoodToInventory(petId, food);
                
                Navigator.pop(context);
                SoundHelper.playSuccessSound();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm thức ăn!')),
                );
              },
              child: Text('add'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaOptionsDialog(BuildContext context, PetService petService, String petId, ImagePicker picker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('add_media'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('take_photo'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromHome(context, petService, petId, picker, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: Text('select_from_gallery'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromHome(context, petService, petId, picker, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: Text('record_video'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromHome(context, petService, petId, picker, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.orange),
              title: Text('select_video'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromHome(context, petService, petId, picker, ImageSource.gallery);
              },
            ),
          ],
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

  Future<void> _pickImageFromHome(BuildContext context, PetService petService, String petId, ImagePicker picker, ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(source: source);
      
      // Nếu user hủy (image == null), không làm gì cả
      if (image == null) {
        return;
      }
      
      if (image != null) {
        final pet = petService.getPetById(petId);
        if (pet != null) {
          // Hiển thị dialog đang lưu
          BuildContext? savingDialogContext;
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                savingDialogContext = context;
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Đang lưu ảnh cho ${pet.name}...'),
                    ],
                  ),
                );
              },
            );
          }
          
          try {
            // Lưu vào PetService
            await petService.addMediaItem(
              petId,
              'photo',
              image.path,
              'Ảnh ${pet.name}',
            );
            
            // Đóng dialog lưu và hiển thị thông báo thành công
            if (context.mounted && savingDialogContext != null) {
              Navigator.pop(savingDialogContext!);
              // Hiển thị thông báo thành công dạng SnackBar (tự động đóng)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Đã tải lên thành công! Ảnh đã được thêm vào gallery của ${pet.name}'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            // Đóng dialog lưu nếu có lỗi
            if (context.mounted && savingDialogContext != null) {
              Navigator.pop(savingDialogContext!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi khi lưu ảnh: ${e.toString()}'),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      // Đảm bảo đóng dialog loading nếu có lỗi
      if (context.mounted) {
        // Đóng dialog loading nếu vẫn còn
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst || !route.isActive);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickVideoFromHome(BuildContext context, PetService petService, String petId, ImagePicker picker, ImageSource source) async {
    try {
      final XFile? video = await picker.pickVideo(source: source);
      
      // Nếu user hủy (video == null), không làm gì cả
      if (video == null) {
        return;
      }
      
      if (video != null) {
        final pet = petService.getPetById(petId);
        if (pet != null) {
          // Hiển thị dialog đang lưu
          BuildContext? savingDialogContext;
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                savingDialogContext = context;
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Đang lưu video cho ${pet.name}...'),
                    ],
                  ),
                );
              },
            );
          }
          
          try {
            // Lưu vào PetService
            await petService.addMediaItem(
              petId,
              'video',
              video.path,
              'Video ${pet.name}',
            );
            
            // Đóng dialog lưu và hiển thị thông báo thành công
            if (context.mounted && savingDialogContext != null) {
              Navigator.pop(savingDialogContext!);
              // Hiển thị thông báo thành công dạng SnackBar (tự động đóng)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Đã tải lên thành công! Video đã được thêm vào gallery của ${pet.name}'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            // Đóng dialog lưu nếu có lỗi
            if (context.mounted && savingDialogContext != null) {
              Navigator.pop(savingDialogContext!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi khi lưu video: ${e.toString()}'),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      // Đảm bảo đóng dialog loading nếu có lỗi
      if (context.mounted) {
        // Đóng dialog loading nếu vẫn còn
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst || !route.isActive);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}





