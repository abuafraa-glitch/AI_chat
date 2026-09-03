import 'package:ai_chat/data/datasources/remote/remote_data_source.dart';
import 'package:ai_chat/data/models/payment_model.dart';
import 'package:ai_chat/data/repositories/payment_repository.dart';

/// Remote-backed implementation of [PaymentRepository].
class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl({required RemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final RemoteDataSource _remote;

  @override
  Future<List<PaymentModel>> getPaymentHistory() => _remote.getPaymentHistory();
}
