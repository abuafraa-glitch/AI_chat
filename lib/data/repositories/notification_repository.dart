import 'package:ai_chat/data/models/notification_model.dart';

/// Contract for the current user's notification feed.
abstract interface class NotificationRepository {
  /// Returns notifications available to the current user.
  Future<List<NotificationModel>> getNotifications();
}
