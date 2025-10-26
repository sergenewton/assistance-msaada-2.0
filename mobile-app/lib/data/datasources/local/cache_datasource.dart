import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/exceptions.dart';
import '../../models/report_model.dart';
import '../../models/content_model.dart';
import '../../models/notification_model.dart';

abstract class CacheDataSource {
  // Report caching
  Future<void> cacheReport(ReportModel report);
  Future<List<ReportModel>> getCachedReports(String userId);
  Future<ReportModel?> getCachedReportById(String reportId);
  Future<void> removeCachedReport(String reportId);
  
  // Pending reports (offline mode)
  Future<void> cachePendingReport(ReportModel report);
  Future<List<ReportModel>> getPendingReports();
  Future<void> removePendingReport(String reportId);
  
  // Content caching
  Future<void> cacheContent(ContentModel content);
  Future<List<ContentModel>> getCachedContent(ContentType type);
  Future<ContentModel?> getCachedContentById(String contentId);
  Future<List<ContentModel>> searchCachedContent(String query);
  
  // Notification caching
  Future<void> cacheNotification(NotificationModel notification);
  Future<List<NotificationModel>> getCachedNotifications(String userId);
  
  // Pending actions
  Future<void> cachePendingViewIncrement(String contentId);
  Future<List<String>> getPendingViewIncrements();
  Future<void> removePendingViewIncrement(String contentId);
  
  // Cache management
  Future<void> clearAllCache();
  Future<void> clearExpiredCache();
}

class CacheDataSourceImpl implements CacheDataSource {
  static const String _reportsKey = 'cached_reports';
  static const String _pendingReportsKey = 'pending_reports';
  static const String _contentKey = 'cached_content';
  static const String _notificationsKey = 'cached_notifications';
  static const String _pendingViewIncrementsKey = 'pending_view_increments';
  static const String _cacheTimestampKey = 'cache_timestamp';
  
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  final SharedPreferences sharedPreferences;
  
  CacheDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheReport(ReportModel report) async {
    try {
      final cachedReports = await _getCachedReportsList();
      
      // Remove existing report with same ID
      cachedReports.removeWhere((r) => r.id == report.id);
      
      // Add new report
      cachedReports.add(report);
      
      // Save to shared preferences
      final reportsJson = cachedReports.map((r) => r.toJson()).toList();
      await sharedPreferences.setString(_reportsKey, json.encode(reportsJson));
      await _updateCacheTimestamp();
    } catch (e) {
      throw CacheException('Failed to cache report: $e');
    }
  }

  @override
  Future<List<ReportModel>> getCachedReports(String userId) async {
    try {
      await _checkCacheExpiration();
      final cachedReports = await _getCachedReportsList();
      return cachedReports.where((r) => r.userId == userId).toList();
    } catch (e) {
      throw CacheException('Failed to get cached reports: $e');
    }
  }

  @override
  Future<ReportModel?> getCachedReportById(String reportId) async {
    try {
      await _checkCacheExpiration();
      final cachedReports = await _getCachedReportsList();
      
      for (final report in cachedReports) {
        if (report.id == reportId) {
          return report;
        }
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached report: $e');
    }
  }

  @override
  Future<void> removeCachedReport(String reportId) async {
    try {
      final cachedReports = await _getCachedReportsList();
      cachedReports.removeWhere((r) => r.id == reportId);
      
      final reportsJson = cachedReports.map((r) => r.toJson()).toList();
      await sharedPreferences.setString(_reportsKey, json.encode(reportsJson));
    } catch (e) {
      throw CacheException('Failed to remove cached report: $e');
    }
  }

  @override
  Future<void> cachePendingReport(ReportModel report) async {
    try {
      final pendingReports = await _getPendingReportsList();
      pendingReports.add(report);
      
      final reportsJson = pendingReports.map((r) => r.toJson()).toList();
      await sharedPreferences.setString(_pendingReportsKey, json.encode(reportsJson));
    } catch (e) {
      throw CacheException('Failed to cache pending report: $e');
    }
  }

  @override
  Future<List<ReportModel>> getPendingReports() async {
    try {
      return await _getPendingReportsList();
    } catch (e) {
      throw CacheException('Failed to get pending reports: $e');
    }
  }

  @override
  Future<void> removePendingReport(String reportId) async {
    try {
      final pendingReports = await _getPendingReportsList();
      pendingReports.removeWhere((r) => r.id == reportId);
      
      final reportsJson = pendingReports.map((r) => r.toJson()).toList();
      await sharedPreferences.setString(_pendingReportsKey, json.encode(reportsJson));
    } catch (e) {
      throw CacheException('Failed to remove pending report: $e');
    }
  }

  @override
  Future<void> cacheContent(ContentModel content) async {
    try {
      final cachedContent = await _getCachedContentList();
      
      // Remove existing content with same ID
      cachedContent.removeWhere((c) => c.id == content.id);
      
      // Add new content
      cachedContent.add(content);
      
      // Keep only recent content (limit to 100 items)
      if (cachedContent.length > 100) {
        cachedContent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        cachedContent.removeRange(100, cachedContent.length);
      }
      
      // Save to shared preferences
      final contentJson = cachedContent.map((c) => c.toJson()).toList();
      await sharedPreferences.setString(_contentKey, json.encode(contentJson));
      await _updateCacheTimestamp();
    } catch (e) {
      throw CacheException('Failed to cache content: $e');
    }
  }

  @override
  Future<List<ContentModel>> getCachedContent(ContentType type) async {
    try {
      await _checkCacheExpiration();
      final cachedContent = await _getCachedContentList();
      return cachedContent.where((c) => c.type == type).toList();
    } catch (e) {
      throw CacheException('Failed to get cached content: $e');
    }
  }

  @override
  Future<ContentModel?> getCachedContentById(String contentId) async {
    try {
      await _checkCacheExpiration();
      final cachedContent = await _getCachedContentList();
      
      for (final content in cachedContent) {
        if (content.id == contentId) {
          return content;
        }
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached content: $e');
    }
  }

  @override
  Future<List<ContentModel>> searchCachedContent(String query) async {
    try {
      await _checkCacheExpiration();
      final cachedContent = await _getCachedContentList();
      final lowercaseQuery = query.toLowerCase();
      
      return cachedContent.where((content) {
        return content.title.toLowerCase().contains(lowercaseQuery) ||
            content.description.toLowerCase().contains(lowercaseQuery) ||
            content.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      throw CacheException('Failed to search cached content: $e');
    }
  }

  @override
  Future<void> cacheNotification(NotificationModel notification) async {
    try {
      final cachedNotifications = await _getCachedNotificationsList();
      
      // Remove existing notification with same ID
      cachedNotifications.removeWhere((n) => n.id == notification.id);
      
      // Add new notification
      cachedNotifications.add(notification);
      
      // Keep only recent notifications (limit to 50 items)
      if (cachedNotifications.length > 50) {
        cachedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        cachedNotifications.removeRange(50, cachedNotifications.length);
      }
      
      // Save to shared preferences
      final notificationsJson = cachedNotifications.map((n) => n.toJson()).toList();
      await sharedPreferences.setString(_notificationsKey, json.encode(notificationsJson));
      await _updateCacheTimestamp();
    } catch (e) {
      throw CacheException('Failed to cache notification: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getCachedNotifications(String userId) async {
    try {
      await _checkCacheExpiration();
      final cachedNotifications = await _getCachedNotificationsList();
      return cachedNotifications.where((n) => n.userId == userId).toList();
    } catch (e) {
      throw CacheException('Failed to get cached notifications: $e');
    }
  }

  @override
  Future<void> cachePendingViewIncrement(String contentId) async {
    try {
      final pendingViewIncrements = await getPendingViewIncrements();
      if (!pendingViewIncrements.contains(contentId)) {
        pendingViewIncrements.add(contentId);
        await sharedPreferences.setStringList(_pendingViewIncrementsKey, pendingViewIncrements);
      }
    } catch (e) {
      throw CacheException('Failed to cache pending view increment: $e');
    }
  }

  @override
  Future<List<String>> getPendingViewIncrements() async {
    try {
      return sharedPreferences.getStringList(_pendingViewIncrementsKey) ?? [];
    } catch (e) {
      throw CacheException('Failed to get pending view increments: $e');
    }
  }

  @override
  Future<void> removePendingViewIncrement(String contentId) async {
    try {
      final pendingViewIncrements = await getPendingViewIncrements();
      pendingViewIncrements.remove(contentId);
      await sharedPreferences.setStringList(_pendingViewIncrementsKey, pendingViewIncrements);
    } catch (e) {
      throw CacheException('Failed to remove pending view increment: $e');
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      await sharedPreferences.remove(_reportsKey);
      await sharedPreferences.remove(_pendingReportsKey);
      await sharedPreferences.remove(_contentKey);
      await sharedPreferences.remove(_notificationsKey);
      await sharedPreferences.remove(_pendingViewIncrementsKey);
      await sharedPreferences.remove(_cacheTimestampKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    final cacheTimestamp = sharedPreferences.getInt(_cacheTimestampKey);
    if (cacheTimestamp != null) {
      final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheDate) > _cacheExpiration) {
        await clearAllCache();
      }
    }
  }

  // Private helper methods
  Future<List<ReportModel>> _getCachedReportsList() async {
    final reportsString = sharedPreferences.getString(_reportsKey);
    if (reportsString == null) return [];
    
    final List<dynamic> reportsJson = json.decode(reportsString);
    return reportsJson.map((json) => ReportModel.fromJson(json)).toList();
  }

  Future<List<ReportModel>> _getPendingReportsList() async {
    final reportsString = sharedPreferences.getString(_pendingReportsKey);
    if (reportsString == null) return [];
    
    final List<dynamic> reportsJson = json.decode(reportsString);
    return reportsJson.map((json) => ReportModel.fromJson(json)).toList();
  }

  Future<List<ContentModel>> _getCachedContentList() async {
    final contentString = sharedPreferences.getString(_contentKey);
    if (contentString == null) return [];
    
    final List<dynamic> contentJson = json.decode(contentString);
    return contentJson.map((json) => ContentModel.fromJson(json)).toList();
  }

  Future<List<NotificationModel>> _getCachedNotificationsList() async {
    final notificationsString = sharedPreferences.getString(_notificationsKey);
    if (notificationsString == null) return [];
    
    final List<dynamic> notificationsJson = json.decode(notificationsString);
    return notificationsJson.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> _updateCacheTimestamp() async {
    await sharedPreferences.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _checkCacheExpiration() async {
    final cacheTimestamp = sharedPreferences.getInt(_cacheTimestampKey);
    if (cacheTimestamp != null) {
      final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheDate) > _cacheExpiration) {
        await clearAllCache();
        throw CacheException('Cache has expired');
      }
    }
  }
}