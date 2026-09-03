import 'package:ai_chat/data/models/payment_model.dart';

/// Contract for payment-history operations.
abstract interface class PaymentRepository {
  /// Returns payment records owned by the current user.
  Future<List<PaymentModel>> getPaymentHistory();
}
