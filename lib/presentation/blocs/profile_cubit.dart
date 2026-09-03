import 'package:ai_chat/data/repositories/user_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class ProfileState extends Equatable {
  const ProfileState({this.user, this.isLoading = false, this.error});

  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  ProfileState copyWith({
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
  }) => ProfileState(user: user ?? this.user, isLoading: isLoading ?? this.isLoading, error: error);

  @override
  List<Object?> get props => <Object?>[user, isLoading, error];
}

/// Loads the authenticated profile through UserRepository.
final class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required UserRepository repository})
    : _repository = repository,
      super(const ProfileState());

  final UserRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final user = await _repository.getCurrentUser();
      emit(ProfileState(user: user, isLoading: false));
    } on Exception catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }
}
