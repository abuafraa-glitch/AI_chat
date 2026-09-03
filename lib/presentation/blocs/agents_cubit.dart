import 'package:ai_chat/data/repositories/agent_repository.dart';
import 'package:ai_chat/data/models/agent_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the agents catalogue.
final class AgentsState extends Equatable {
  /// Creates an [AgentsState].
  const AgentsState({
    this.items = const <AgentModel>[],
    this.isLoading = false,
    this.error,
  });

  /// Agent definitions.
  final List<AgentModel> items;

  /// `true` while the catalogue is being fetched.
  final bool isLoading;

  /// Human-readable error message, or `null` when healthy.
  final String? error;

  /// Returns a copy with the given fields replaced.
  AgentsState copyWith({
    List<AgentModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return AgentsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[items, isLoading, error];
}

/// Manages the AI agent catalogue.
final class AgentsCubit extends Cubit<AgentsState> {
  /// Creates an [AgentsCubit] wired to [repository].
  AgentsCubit({required AgentRepository repository})
    : _repository = repository,
      super(const AgentsState());

  final AgentRepository _repository;

  /// Loads the agent catalogue.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repository.getAgents();
      emit(state.copyWith(items: items, isLoading: false));
    } on Exception catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }
}
