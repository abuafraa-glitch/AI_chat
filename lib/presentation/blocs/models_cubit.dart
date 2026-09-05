import 'package:ai_chat/data/models/ai_model.dart';
import 'package:ai_chat/data/repositories/ai_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the AI model catalogue and current selection.
final class ModelsState extends Equatable {
  /// Creates a [ModelsState].
  const ModelsState({
    this.models = const <AIModel>[],
    this.selectedModelId,
    this.isLoading = false,
    this.error,
  });

  /// Available AI models.
  final List<AIModel> models;

  /// Identifier of the currently selected model, or `null`.
  final String? selectedModelId;

  /// `true` while the catalogue is being fetched.
  final bool isLoading;

  /// Human-readable error message, or `null` when healthy.
  final String? error;

  /// Returns a copy with the given fields replaced.
  ModelsState copyWith({
    List<AIModel>? models,
    String? selectedModelId,
    bool? isLoading,
    String? error,
  }) {
    return ModelsState(
      models: models ?? this.models,
      selectedModelId: selectedModelId ?? this.selectedModelId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    models,
    selectedModelId,
    isLoading,
    error,
  ];
}

/// Manages the AI model catalogue and the user's current selection.
///
/// Loads the catalogue through [AIRepository] and keeps only backend-provided
/// selection state. No local or hardcoded model is supplied.
final class ModelsCubit extends Cubit<ModelsState> {
  /// Creates a [ModelsCubit] wired to [repository].
  ModelsCubit({required AIRepository repository, this.defaultModelId})
    : _repository = repository,
      super(ModelsState(selectedModelId: defaultModelId));

  final AIRepository _repository;

  /// Model used when the provider does not expose an application catalogue.
  final String? defaultModelId;

  /// Loads the AI model catalogue.
  Future<void> loadModels() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final models = await _repository.getModels().timeout(
        const Duration(seconds: 12),
      );
      final currentIsAvailable = models.any(
        (model) => model.id == state.selectedModelId && model.isAvailable,
      );
      final configuredIsAvailable = models.any(
        (model) => model.id == defaultModelId && model.isAvailable,
      );
      String? selectedModelId = currentIsAvailable
          ? state.selectedModelId
          : (configuredIsAvailable || models.isEmpty ? defaultModelId : null);
      emit(
        state.copyWith(
          models: models,
          selectedModelId: selectedModelId,
          isLoading: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  /// Selects [modelId] as the active model.
  void selectModel(String? modelId) {
    emit(state.copyWith(selectedModelId: modelId));
  }

  /// Returns the active backend-provided model, or `null` when none is selected.
  String? ensureDefaultSelection() {
    final current = state.selectedModelId;
    if (current != null &&
        state.models.any((model) => model.id == current && model.isAvailable)) {
      return current;
    }
    return current;
  }
}
