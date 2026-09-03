import 'package:ai_chat/data/repositories/notification_repository.dart';
import 'package:ai_chat/data/models/notification_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the notification feed.
final class NotificationsState extends Equatable {
  /// Creates a [NotificationsState].
  const NotificationsState({
    this.items = const <NotificationModel>[],
    this.isLoading = false,
    this.error,
  });

  /// Notification feed.
  final List<NotificationModel> items;

  /// `true` while the feed is being fetched.
  final bool isLoading;

  /// Human-readable error message, or `null` when healthy.
  final String? error;

  /// Returns a copy with the given fields replaced.
  NotificationsState copyWith({
    List<NotificationModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[items, isLoading, error];
}

/// Manages the in-app notification feed.
final class NotificationsCubit extends Cubit<NotificationsState> {
  /// Creates a [NotificationsCubit] wired to [repository].
  NotificationsCubit({required NotificationRepository repository})
    : _repository = repository,
      super(const NotificationsState());

  final NotificationRepository _repository;

  /// Loads the notification feed.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repository.getNotifications();
      emit(state.copyWith(items: items, isLoading: false));
    } on Exception catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }
}
