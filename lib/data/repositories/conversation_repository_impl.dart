import 'package:ai_chat/data/datasources/remote/remote_data_source.dart';
import 'package:ai_chat/data/models/conversation_model.dart';
import 'package:ai_chat/data/repositories/conversation_repository.dart';

/// Implementation of [ConversationRepository].
///
/// Orchestrates conversation data through the remote source.
/// Local storage is not used as a substitute for backend data.
class ConversationRepositoryImpl implements ConversationRepository {
  /// Creates a [ConversationRepositoryImpl] wired to
  /// [remoteDataSource] and [localDataSource].
  ConversationRepositoryImpl({
    required RemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final RemoteDataSource _remote;

  @override
  Future<List<ConversationModel>> getConversations() => _remote.getConversations();

  @override
  Future<ConversationModel> createConversation(
    Map<String, dynamic> data,
  ) async {
    final conversation = await _remote.createConversation(data);
    return conversation;
  }

  @override
  Future<ConversationModel> updateConversation({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final updated = await _remote.updateConversation(id: id, data: data);
    return updated;
  }

  @override
  Future<void> deleteConversation(String id) async {
    await _remote.deleteConversation(id);
  }

  @override
  Future<List<ConversationModel>> searchConversations(String query) =>
      _remote.searchConversations(query);

}
