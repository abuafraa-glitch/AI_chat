import 'package:ai_chat/data/datasources/remote/remote_data_source.dart';
import 'package:ai_chat/data/models/agent_model.dart';
import 'package:ai_chat/data/repositories/agent_repository.dart';

/// Remote-backed implementation of [AgentRepository].
class AgentRepositoryImpl implements AgentRepository {
  const AgentRepositoryImpl({required RemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final RemoteDataSource _remote;

  @override
  Future<List<AgentModel>> getAgents() => _remote.getAgents();
}
