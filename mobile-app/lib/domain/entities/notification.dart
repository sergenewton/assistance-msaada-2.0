import 'package:equatable/equatable.dart';

enum NotificationType {
  info,
  warning,
  success,
  error,
  reportUpdate,
  newMessage,
  systemAlert,
  reminder,
}

class Notification extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? actionUrl;

  const Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
    this.actionUrl,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        type,
        createdAt,
        isRead,
        data,
        actionUrl,
      ];

  /// Get display name for notification type
  String get typeDisplayName {
    switch (type) {
      case NotificationType.info:
        return 'Information';
      case NotificationType.warning:
        return 'Avertissement';
      case NotificationType.success:
        return 'Succès';
      case NotificationType.error:
        return 'Erreur';
      case NotificationType.reportUpdate:
        return 'Mise à jour du signalement';
      case NotificationType.newMessage:
        return 'Nouveau message';
      case NotificationType.systemAlert:
        return 'Alerte système';
      case NotificationType.reminder:
        return 'Rappel';
    }
  }

  /// Check if notification is unread
  bool get isUnread => !isRead;

  /// Check if notification has action
  bool get hasAction => actionUrl != null && actionUrl!.isNotEmpty;

  /// Get notification priority level
  int get priority {
    switch (type) {
      case NotificationType.error:
      case NotificationType.systemAlert:
        return 3; // High priority
      case NotificationType.warning:
      case NotificationType.reportUpdate:
        return 2; // Medium priority
      case NotificationType.info:
      case NotificationType.success:
      case NotificationType.newMessage:
      case NotificationType.reminder:
        return 1; // Low priority
    }
  }

  /// Check if notification is high priority
  bool get isHighPriority => priority >= 3;

  /// Check if notification is medium priority
  bool get isMediumPriority => priority == 2;

  /// Check if notification is low priority
  bool get isLowPriority => priority == 1;

  /// Get time since creation
  Duration get timeSinceCreation => DateTime.now().difference(createdAt);

  /// Check if notification is recent (less than 24 hours)
  bool get isRecent => timeSinceCreation.inHours < 24;

  /// Get data value by key
  T? getData<T>(String key, [T? defaultValue]) {
    if (data == null) return defaultValue;
    return data![key] as T? ?? defaultValue;
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  /// Mark notification as read
  Notification markAsRead() {
    return copyWith(isRead: true);
  }

  /// Mark notification as unread
  Notification markAsUnread() {
    return copyWith(isRead: false);
  }
}