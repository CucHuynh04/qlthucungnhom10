// lib/common_app_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'notification_service.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showNotificationBell;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showNotificationBell = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.teal[700],
      foregroundColor: Colors.white,
      automaticallyImplyLeading: true,
      actions: [
        if (showNotificationBell) ...[
          Consumer<NotificationService>(
            builder: (context, notificationService, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    tooltip: 'notifications'.tr(),
                    onPressed: () => _showNotifications(context, notificationService),
                  ),
                  if (notificationService.hasUnreadNotifications)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        if (actions != null) ...actions!,
      ],
    );
  }

  void _showNotifications(BuildContext context, NotificationService notificationService) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 60, left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal[700],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thông báo lịch hẹn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (notificationService.notifications.isNotEmpty)
                                Flexible(
                                  child: TextButton(
                                    onPressed: () {
                                      notificationService.markAllAsRead();
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    child: const Text(
                                      'Đánh dấu đã đọc',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, color: Colors.white),
                                tooltip: 'Đóng',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: notificationService.notifications.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Không có thông báo nào',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: notificationService.notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notificationService.notifications[index];
                              final isRead = notification['isRead'] as bool;
                              
                              return Card(
                                margin: const EdgeInsets.all(8),
                                color: isRead ? Colors.grey[100] : Colors.blue[50],
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: notification['type'] == 'vaccination' 
                                        ? Colors.red 
                                        : Colors.teal,
                                    child: Icon(
                                      notification['type'] == 'vaccination' 
                                          ? Icons.medical_services 
                                          : Icons.event,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    notification['title'],
                                    style: TextStyle(
                                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(notification['message']),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ngày: ${notification['date'].day}/${notification['date'].month}/${notification['date'].year}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: isRead 
                                      ? null 
                                      : IconButton(
                                          icon: const Icon(Icons.check_circle_outline),
                                          onPressed: () {
                                            notificationService.markAsRead(notification['id']);
                                          },
                                        ),
                                  onTap: () {
                                    if (!isRead) {
                                      notificationService.markAsRead(notification['id']);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}





