import 'package:ai_chat/data/datasources/remote/remote_data_source.dart';
import 'package:ai_chat/data/models/ai_model.dart';
import 'package:ai_chat/data/repositories/ai_repository.dart';

/// Implementation of [AIRepository].
///
/// Retrieves the AI model catalogue from the remote source only.
/// Backend data is never replaced by local cache data.
class AIRepositoryImpl implements AIRepository {
  /// Creates an [AIRepositoryImpl] wired to [remoteDataSource].
  AIRepositoryImpl({
    required RemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final RemoteDataSource _remote;

  @override
  Future<List<AIModel>> getModels() => _remote.getModels();

  @override
  Future<AIModel> getModelDetails(String modelId) =>
      _remote.getModelDetails(modelId);

}
