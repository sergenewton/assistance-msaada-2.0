import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<Notification>>> getUserNotifications(String userId);
  Future<Either<Failure, Notification>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead(String userId);
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Future<Either<Failure, int>> getUnreadCount(String userId);
}

class GetNotifications {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  Future<Either<Failure, NotificationResult>> call(String userId) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure('User ID is required'));
    }

    final notificationsResult = await repository.getUserNotifications(userId);
    
    return notificationsResult.fold(
      (failure) => Left(failure),
      (notifications) async {
        final unreadResult = await repository.getUnreadCount(userId);
        
        return unreadResult.fold(
          (failure) => Left(failure),
          (unreadCount) {
            final result = NotificationResult(
              notifications: notifications,
              unreadCount: unreadCount,
              categorizedNotifications: _categorizeNotifications(notifications),
            );
            return Right(result);
          },
        );
      },
    );
  }

  Map<NotificationType, List<Notification>> _categorizeNotifications(
      List<Notification> notifications) {
    final categorized = <NotificationType, List<Notification>>{};
    
    for (final notification in notifications) {
      if (!categorized.containsKey(notification.type)) {
        categorized[notification.type] = [];
      }
      categorized[notification.type]!.add(notification);
    }
    
    // Sort each category by creation date (newest first)
    for (final category in categorized.keys) {
      categorized[category]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return categorized;
  }
}

class NotificationResult {
  final List<Notification> notifications;
  final int unreadCount;
  final Map<NotificationType, List<Notification>> categorizedNotifications;

  NotificationResult({
    required this.notifications,
    required this.unreadCount,
    required this.categorizedNotifications,
  });

  /// Get notifications by priority
  List<Notification> get highPriorityNotifications {
    return notifications.where((n) => n.isHighPriority).toList();
  }

  List<Notification> get mediumPriorityNotifications {
    return notifications.where((n) => n.isMediumPriority).toList();
  }

  List<Notification> get lowPriorityNotifications {
    return notifications.where((n) => n.isLowPriority).toList();
  }

  /// Get unread notifications
  List<Notification> get unreadNotifications {
    return notifications.where((n) => n.isUnread).toList();
  }

  /// Get recent notifications (last 24 hours)
  List<Notification> get recentNotifications {
    return notifications.where((n) => n.isRecent).toList();
  }

  /// Check if there are any unread notifications
  bool get hasUnreadNotifications => unreadCount > 0;

  /// Check if there are any high priority notifications
  bool get hasHighPriorityNotifications => 
      notifications.any((n) => n.isHighPriority);
}