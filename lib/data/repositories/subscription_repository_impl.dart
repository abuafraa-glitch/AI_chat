import 'package:ai_chat/data/datasources/remote/remote_data_source.dart';
import 'package:ai_chat/data/models/subscription_model.dart';
import 'package:ai_chat/data/models/subscription_plan_model.dart';
import 'package:ai_chat/data/repositories/subscription_repository.dart';

/// Implementation of [SubscriptionRepository].
///
/// Handles subscription plans and the user's active subscription through the
/// remote source. Subscription status is never inferred from local storage.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  /// Creates a [SubscriptionRepositoryImpl] wired to
  /// [remoteDataSource] and [localDataSource].
  SubscriptionRepositoryImpl({
    required RemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final RemoteDataSource _remote;

  @override
  Future<List<SubscriptionPlanModel>> getPlans() =>
      _remote.getSubscriptionPlans();

  @override
  Future<SubscriptionModel> getSubscription() => _remote.getSubscription();

  @override
  Future<void> cancelSubscription(String subscriptionId) =>
      _remote.cancelSubscription(subscriptionId);

}
