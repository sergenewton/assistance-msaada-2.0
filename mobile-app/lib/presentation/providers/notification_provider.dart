import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_notifications.dart';

// State classes
class NotificationState {
  final List<Notification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  final Map<NotificationType, List<Notification>> categorizedNotifications;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.categorizedNotifications = const {},
  });

  NotificationState copyWith({
    List<Notification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
    Map<NotificationType, List<Notification>>? categorizedNotifications,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categorizedNotifications: categorizedNotifications ?? this.categorizedNotifications,
    );
  }
}

// Notification provider
class NotificationNotifier extends StateNotifier<NotificationState> {
  final GetNotifications getNotificationsUseCase;

  NotificationNotifier({
    required this.getNotificationsUseCase,
  }) : super(const NotificationState());

  Future<void> loadNotifications(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getNotificationsUseCase(userId);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (notificationResult) => state = state.copyWith(
        isLoading: false,
        notifications: notificationResult.notifications,
        unreadCount: notificationResult.unreadCount,
        categorizedNotifications: notificationResult.categorizedNotifications,
        error: null,
      ),
    );
  }

  void markAsRead(String notificationId) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId && !notification.isRead) {
        return notification.markAsRead();
      }
      return notification;
    }).toList();

    final newUnreadCount = updatedNotifications.where((n) => n.isUnread).length;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }

  void markAllAsRead() {
    final updatedNotifications = state.notifications.map((notification) {
      return notification.markAsRead();
    }).toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    );
  }

  void removeNotification(String notificationId) {
    final updatedNotifications = state.notifications
        .where((notification) => notification.id != notificationId)
        .toList();
    
    final newUnreadCount = updatedNotifications.where((n) => n.isUnread).length;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider instances - these would be properly injected with dependencies
final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  // This would be injected through dependency injection
  throw UnimplementedError('Dependencies need to be injected');
});

// Individual providers for specific data
final notificationsListProvider = Provider<List<Notification>>((ref) {
  return ref.watch(notificationProvider).notifications;
});

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

final notificationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).isLoading;
});

final notificationErrorProvider = Provider<String?>((ref) {
  return ref.watch(notificationProvider).error;
});

final categorizedNotificationsProvider = Provider<Map<NotificationType, List<Notification>>>((ref) {
  return ref.watch(notificationProvider).categorizedNotifications;
});

// Derived providers
final unreadNotificationsProvider = Provider<List<Notification>>((ref) {
  return ref.watch(notificationsListProvider).where((n) => n.isUnread).toList();
});

final highPriorityNotificationsProvider = Provider<List<Notification>>((ref) {
  return ref.watch(notificationsListProvider).where((n) => n.isHighPriority).toList();
});

final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(unreadCountProvider) > 0;
});