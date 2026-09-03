import 'package:ai_chat/data/datasources/remote/remote_data_source.dart';
import 'package:ai_chat/data/models/notification_model.dart';
import 'package:ai_chat/data/repositories/notification_repository.dart';

/// Remote-backed implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({required RemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final RemoteDataSource _remote;

  @override
  Future<List<NotificationModel>> getNotifications() => _remote.getNotifications();
}
