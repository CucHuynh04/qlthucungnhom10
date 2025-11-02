import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'pet_service.dart';
import 'pet_detail_screen.dart';
import 'filter_search_screen.dart';
import 'common_app_bar.dart';
import 'dart:io';

/// Widget hiển thị shimmer khi hover
class HoverShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const HoverShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<HoverShimmer> createState() => _HoverShimmerState();
}

class _HoverShimmerState extends State<HoverShimmer> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: _isHovering
          ? widget.child.animate()
              .shimmer(duration: widget.duration)
          : widget.child,
    );
  }
} 

class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetService>( 
      builder: (context, petService, child) {
        return Scaffold(
          extendBody: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: petService.pets.isEmpty
                ? Center(child: Text('no_pets_yet'.tr()))
                : ListView.builder(
                  itemCount: petService.pets.length, 
                  itemBuilder: (context, index) {
                    final pet = petService.pets[index];
                    final card = Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal[100],
                          // HIỂN THỊ ẢNH THUMBNAIL TỪ FILE PATH
                          backgroundImage: pet.imageUrl != null ? FileImage(File(pet.imageUrl!)) : null,
                          child: pet.imageUrl == null
                              ? const Icon(Icons.pets, color: Colors.teal) // Icon mặc định nếu không có ảnh
                              : null,
                        ),
                        title: Text(
                          pet.name, 
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${pet.species} - ${pet.breed}'), 
                        
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
                    
                    // Wrap với HoverShimmer để hiển thị shimmer khi hover
                    return HoverShimmer(child: card);
                  },
                ),
          ),
        );
      },
    );
  }
}




