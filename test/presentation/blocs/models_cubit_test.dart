import 'package:ai_chat/data/models/ai_model.dart';
import 'package:ai_chat/data/repositories/ai_repository.dart';
import 'package:ai_chat/presentation/blocs/models_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingAIRepository implements AIRepository {
  @override
  Future<List<AIModel>> getModels() async {
    throw StateError('catalogue unavailable');
  }

  @override
  Future<AIModel> getModelDetails(String modelId) async {
    throw UnimplementedError();
  }
}

void main() {
  test('keeps the catalogue empty when Backend is unavailable', () async {
    final cubit = ModelsCubit(repository: _FailingAIRepository());

    await cubit.loadModels();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.models, isEmpty);
    expect(cubit.state.selectedModelId, isNull);
    expect(cubit.state.error, contains('catalogue unavailable'));

    await cubit.close();
  });
}
