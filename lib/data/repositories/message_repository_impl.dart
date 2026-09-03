import 'package:ai_chat/data/datasources/remote/remote_data_source.dart';
import 'package:ai_chat/data/models/message_model.dart';
import 'package:ai_chat/data/repositories/message_repository.dart';

/// Implementation of [MessageRepository].
///
/// Manages message history, sending, streaming and regeneration through the
/// remote source. Local storage is never a backend-data fallback.
class MessageRepositoryImpl implements MessageRepository {
  /// Creates a [MessageRepositoryImpl] wired to [remoteDataSource] and
  /// [localDataSource].
  MessageRepositoryImpl({
    required RemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final RemoteDataSource _remote;

  @override
  Future<List<MessageModel>> getMessages(String conversationId) =>
      _remote.getConversationMessages(conversationId);

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required Map<String, dynamic> data,
  }) async {
    final message = await _remote.sendMessage(
      conversationId: conversationId,
      data: data,
    );
    return message;
  }

  @override
  Stream<String> streamMessage({
    required String conversationId,
    Map<String, dynamic>? data,
    String? cancelToken,
  }) {
    return _remote.streamMessage(
      conversationId: conversationId,
      data: data,
      cancelToken: cancelToken,
    );
  }

  @override
  void cancelStream(String? cancelToken) => _remote.cancelStream(cancelToken);

  @override
  Future<MessageModel> regenerateMessage({
    required String conversationId,
    required String messageId,
  }) async {
    final message = await _remote.regenerateMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
    return message;
  }

  @override
  Future<void> cacheMessages(
    String conversationId,
    List<MessageModel> messages,
  ) async {
    // Intentionally no-op: backend-owned messages must not be cached as a
    // fallback. The method remains for compatibility with the current API.
  }

}
