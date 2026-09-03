import 'package:ai_chat/data/models/subscription_model.dart';
import 'package:ai_chat/data/models/subscription_plan_model.dart';
import 'package:ai_chat/data/repositories/subscription_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for subscription plans and the active subscription.
final class SubscriptionsState extends Equatable {
  /// Creates a [SubscriptionsState].
  const SubscriptionsState({
    this.plans = const <SubscriptionPlanModel>[],
    this.currentSubscription,
    this.isLoading = false,
    this.error,
  });

  /// Available subscription plans.
  final List<SubscriptionPlanModel> plans;

  /// The user's active subscription, or `null` when none exists.
  final SubscriptionModel? currentSubscription;

  /// `true` while data is being fetched.
  final bool isLoading;

  /// Human-readable error message, or `null` when healthy.
  final String? error;

  /// Returns a copy with the given fields replaced.
  SubscriptionsState copyWith({
    List<SubscriptionPlanModel>? plans,
    SubscriptionModel? currentSubscription,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionsState(
      plans: plans ?? this.plans,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    plans,
    currentSubscription,
    isLoading,
    error,
  ];
}

/// Manages subscription plans and the user's active subscription.
///
/// Data is loaded through [SubscriptionRepository] from the backend contract.
/// A `null` current subscription simply means that no active subscription was
/// returned; no local or fabricated fallback is used.
final class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  /// Creates a [SubscriptionsCubit] wired to [repository].
  SubscriptionsCubit({required SubscriptionRepository repository})
    : _repository = repository,
      super(const SubscriptionsState());

  final SubscriptionRepository _repository;

  /// Loads subscription plans and the active subscription.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    await _loadPlans(_repository);
    await _loadCurrentSubscription(_repository);
    emit(state.copyWith(isLoading: false));
  }

  /// Loads the available plans; failures are surfaced in the state.
  Future<void> _loadPlans(SubscriptionRepository repository) async {
    try {
      final plans = await repository.getPlans();
      emit(state.copyWith(plans: plans));
    } on Exception catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }

  /// Loads the active subscription from the backend contract.

  Future<void> _loadCurrentSubscription(SubscriptionRepository repository) async {
    try {
      final subscription = await repository.getSubscription();
      emit(state.copyWith(currentSubscription: subscription));
    } on Exception {
      // An account without an active subscription is a valid empty state.
    }
  }
}
