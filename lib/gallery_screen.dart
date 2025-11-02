// lib/gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'pet_service.dart';
import 'dart:io';

class GalleryScreen extends StatefulWidget {
  final Function(bool)? onPetSelectedChanged; // Callback để thông báo khi chọn/bỏ chọn pet
  final Function(String?)? onPetIdChanged; // Callback để truyền selectedPetId cho HomePage
  
  const GalleryScreen({super.key, this.onPetSelectedChanged, this.onPetIdChanged});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String? _selectedPetId;
  String _selectedMediaType = 'all'; // 'all', 'photos', 'videos'
  final ImagePicker _picker = ImagePicker();
  final Set<String> _selectedItems = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final petService = context.watch<PetService>();
    final pets = petService.pets;
    
    // Đảm bảo _selectedPetId vẫn hợp lệ sau khi PetService thay đổi
    if (_selectedPetId != null) {
      final pet = petService.getPetById(_selectedPetId!);
      if (pet == null && pets.isNotEmpty) {
        // Pet đã bị xóa, reset selectedPetId
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedPetId = null;
            });
            if (widget.onPetSelectedChanged != null) {
              widget.onPetSelectedChanged!(false);
            }
            if (widget.onPetIdChanged != null) {
              widget.onPetIdChanged!(null);
            }
          }
        });
      }
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // Hiển thị danh sách thú cưng hoặc gallery
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
                                        // Thông báo cho HomePage khi đã chọn pet
                                        if (widget.onPetSelectedChanged != null) {
                                          widget.onPetSelectedChanged!(true);
                                        }
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
                    // Hiển thị gallery
                    : Stack(
                        children: [
                          _buildGallery(petService),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedPetId = null;
                                });
                                // Thông báo cho HomePage khi bỏ chọn pet
                                if (widget.onPetSelectedChanged != null) {
                                  widget.onPetSelectedChanged!(false);
                                }
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

  Widget _buildGallery(PetService petService) {
    // Đảm bảo _selectedPetId vẫn hợp lệ
    if (_selectedPetId == null) {
      return const SizedBox.shrink();
    }
    
    final pet = petService.getPetById(_selectedPetId!);
    if (pet == null) {
      // Nếu pet không tồn tại, quay về màn hình chọn pet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedPetId = null;
          });
          if (widget.onPetSelectedChanged != null) {
            widget.onPetSelectedChanged!(false);
          }
          if (widget.onPetIdChanged != null) {
            widget.onPetIdChanged!(null);
          }
        }
      });
      return const SizedBox.shrink();
    }

    // Load media items từ PetService
    final mediaItemsFromService = petService.getMediaItems(_selectedPetId!);
    
    // Chuyển đổi MediaItem thành Map để tương thích với code cũ
    final List<Map<String, dynamic>> mediaItems = mediaItemsFromService.map((item) => {
      'id': item.id,
      'type': item.type,
      'path': item.path,
      'date': item.date,
      'title': item.title,
    }).toList();

    final filteredMedia = _filterMedia(mediaItems);

    if (filteredMedia.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có ảnh/video nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Nhấn nút + để thêm ảnh/video mới',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: filteredMedia.length,
      itemBuilder: (context, index) {
        final media = filteredMedia[index];
        return _buildMediaCard(media);
      },
    );
  }

  Widget _buildMediaCard(Map<String, dynamic> media) {
    final isSelected = _selectedItems.contains(media['id']);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: Colors.teal, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _isSelectionMode ? _toggleSelection(media['id']) : _showMediaDetail(media),
        onLongPress: () => _enterSelectionMode(),
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey[200],
                    ),
                    child: media['path'] != null && File(media['path']).existsSync()
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.file(
                              File(media['path']),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    media['type'] == 'video' ? Icons.videocam : Icons.photo,
                                    size: 48,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Icon(
                              media['type'] == 'video' ? Icons.videocam : Icons.photo,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        media['title'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${media['date'].day}/${media['date'].month}/${media['date'].year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterMedia(List<Map<String, dynamic>> media) {
    switch (_selectedMediaType) {
      case 'photos':
        return media.where((m) => m['type'] == 'photo').toList();
      case 'videos':
        return media.where((m) => m['type'] == 'video').toList();
      default:
        return media;
    }
  }

  void _showMediaDetail(Map<String, dynamic> media) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: media['path'] != null && File(media['path']).existsSync()
                      ? media['type'] == 'photo'
                          ? Image.file(
                              File(media['path']),
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo,
                                        size: 64,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Không thể tải ảnh',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : _VideoPlayerWidget(videoPath: media['path'])
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                media['type'] == 'video' ? Icons.videocam : Icons.photo,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'File không tồn tại',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                media['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${media['date'].day}/${media['date'].month}/${media['date'].year}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('export_success'.tr())),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: Text('share_info'.tr(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Xóa từ PetService
                        final petService = context.read<PetService>();
                        petService.deleteMediaItem(_selectedPetId!, media['id']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('export_success'.tr())),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: Text('delete'.tr(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMediaDialog(BuildContext context, PetService petService) {
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thú cưng trước')),
      );
      return;
    }

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
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: Text('select_from_gallery'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: Text('record_video'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.orange),
              title: Text('select_video'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.gallery);
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

  Future<void> _pickImage(ImageSource source) async {
    final petService = context.read<PetService>();
    final pet = petService.getPetById(_selectedPetId!);
    
    try {
      final XFile? image = await _picker.pickImage(source: source);
      
      // Nếu user hủy (image == null), không làm gì cả
      if (image == null) {
        return;
      }
      
      if (image != null && pet != null) {
        // Hiển thị đang lưu
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
            _selectedPetId!,
            'photo',
            image.path,
            'Ảnh ${pet.name}',
          );
          
          // Force rebuild để hiển thị ảnh mới - đảm bảo vẫn ở gallery
          if (mounted) {
            // Đảm bảo _selectedPetId vẫn giữ nguyên
            if (_selectedPetId == null) {
              _selectedPetId = pet.id;
            }
            setState(() {});
          }
          
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
                      child: Text('Đã tải lên thành công! Ảnh đã được thêm vào gallery'),
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

  Future<void> _pickVideo(ImageSource source) async {
    final petService = context.read<PetService>();
    final pet = petService.getPetById(_selectedPetId!);
    
    try {
      final XFile? video = await _picker.pickVideo(source: source);
      
      // Nếu user hủy (video == null), không làm gì cả
      if (video == null) {
        return;
      }
      
      if (video != null && pet != null) {
        // Hiển thị đang lưu
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
            _selectedPetId!,
            'video',
            video.path,
            'Video ${pet.name}',
          );
          
          // Force rebuild để hiển thị video mới - đảm bảo vẫn ở gallery
          if (mounted) {
            // Đảm bảo _selectedPetId vẫn giữ nguyên
            if (_selectedPetId == null) {
              _selectedPetId = pet.id;
            }
            setState(() {});
          }
          
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
                      child: Text('Đã tải lên thành công! Video đã được thêm vào gallery'),
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

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedItems.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _deleteSelectedItems() {
    if (_selectedItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete'.tr()),
        content: Text('Bạn có chắc muốn xóa ${_selectedItems.length} mục đã chọn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              // Xóa từ PetService
              final petService = context.read<PetService>();
              for (final itemId in _selectedItems) {
                petService.deleteMediaItem(_selectedPetId!, itemId);
              }
              setState(() {
                _selectedItems.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('export_success'.tr())),
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

// Widget riêng để phát video
class _VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  
  const _VideoPlayerWidget({required this.videoPath});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.file(File(widget.videoPath));
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        // Tự động phát video
        _controller!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                'Không thể phát video',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'File: ${widget.videoPath.split('/').last}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Đang tải video...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
        // Nút play/pause overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: _controller!.value.isPlaying
                    ? const SizedBox.shrink()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
        // Hiển thị thời gian phát
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: VideoProgressIndicator(
            _controller!,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.teal,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}




