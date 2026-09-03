import 'package:ai_chat/data/models/agent_model.dart';

/// Contract for the AI-agent catalogue.
abstract interface class AgentRepository {
  /// Returns agents available to the current user.
  Future<List<AgentModel>> getAgents();
}
