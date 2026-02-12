import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool showDismissButton;

  const NotificationTile({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.showDismissButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead 
              ? Colors.grey[300]! 
              : Colors.green[300]!,
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildLeadingIcon(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead 
                      ? FontWeight.normal 
                      : FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  notification.formattedTime,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: showDismissButton
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLeadingIcon() {
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.order:
        icon = Icons.shopping_cart;
        iconColor = Colors.blue;
        break;
      case NotificationType.message:
        icon = Icons.chat_bubble;
        iconColor = Colors.green;
        break;
      case NotificationType.product:
        icon = Icons.inventory;
        iconColor = Colors.orange;
        break;
      case NotificationType.system:
        icon = Icons.notifications;
        iconColor = Colors.grey;
        break;
      case NotificationType.promotion:
        icon = Icons.local_offer;
        iconColor = Colors.red;
        break;
      case NotificationType.review:
        icon = Icons.star;
        iconColor = Colors.amber;
        break;
      case NotificationType.payment:
        icon = Icons.payment;
        iconColor = Colors.purple;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final Function(NotificationModel)? onNotificationTap;
  final Function(NotificationModel)? onNotificationDismiss;
  final String emptyMessage;
  final bool showDismissButton;

  const NotificationList({
    Key? key,
    required this.notifications,
    this.onNotificationTap,
    this.onNotificationDismiss,
    this.emptyMessage = 'No notifications',
    this.showDismissButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return NotificationTile(
          notification: notifications[index],
          onTap: onNotificationTap != null
              ? () => onNotificationTap!(notifications[index])
              : null,
          onDismiss: onNotificationDismiss != null
              ? () => onNotificationDismiss!(notifications[index])
              : null,
          showDismissButton: showDismissButton,
        );
      },
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NotificationBadge({
    Key? key,
    required this.count,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}