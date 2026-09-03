import 'package:ai_chat/data/repositories/payment_repository.dart';
import 'package:ai_chat/data/models/payment_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the payment history screen.
final class PaymentsState extends Equatable {
  /// Creates a [PaymentsState].
  const PaymentsState({
    this.items = const <PaymentModel>[],
    this.isLoading = false,
    this.error,
  });

  /// Payment records.
  final List<PaymentModel> items;

  /// `true` while the history is being fetched.
  final bool isLoading;

  /// Human-readable error message, or `null` when healthy.
  final String? error;

  /// Returns a copy with the given fields replaced.
  PaymentsState copyWith({
    List<PaymentModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return PaymentsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[items, isLoading, error];
}

/// Manages the user's payment history.
final class PaymentsCubit extends Cubit<PaymentsState> {
  /// Creates a [PaymentsCubit] wired to [repository].
  PaymentsCubit({required PaymentRepository repository})
    : _repository = repository,
      super(const PaymentsState());

  final PaymentRepository _repository;

  /// Loads the payment history.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repository.getPaymentHistory();
      emit(state.copyWith(items: items, isLoading: false));
    } on Exception catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }
}
