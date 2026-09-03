import 'package:ai_chat/core/widgets/app_scaffold.dart';
import 'package:ai_chat/core/widgets/empty_state.dart';
import 'package:ai_chat/core/widgets/error_view.dart';
import 'package:ai_chat/core/widgets/loaders/loading_indicator.dart';
import 'package:ai_chat/presentation/blocs/data_sources.dart';
import 'package:ai_chat/presentation/blocs/payments_cubit.dart';
import 'package:ai_chat/presentation/widgets/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Displays payment history returned by the backend contract.
/// Payment creation and checkout are intentionally not implemented here.
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentsCubit>(
      create: (_) => PaymentsCubit(repository: buildPaymentRepository())..load(),
      child: const _PaymentsView(),
    );
  }
}

class _PaymentsView extends StatelessWidget {
  const _PaymentsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PaymentsCubit>();
    final state = cubit.state;
    return AppScaffold(
      appBar: AppBar(title: Text(localizedText(context, 'Payment history', 'سجل الدفع'))),
      body: _content(context, cubit, state),
    );
  }

  Widget _content(BuildContext context, PaymentsCubit cubit, PaymentsState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: LoadingIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return ErrorView(description: state.error, onRetry: cubit.load);
    }
    if (state.items.isEmpty) {
      return EmptyState(
        variant: EmptyStateVariant.custom,
        icon: Icons.receipt_long_outlined,
        title: localizedText(context, 'No payments yet', 'لا توجد عمليات دفع'),
        description: localizedText(
          context,
          'Payment records will appear here when returned by the backend.',
          'ستظهر عمليات الدفع هنا عند إرجاعها من الخادم.',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final item = state.items[index];
        return ListTile(
          leading: const Icon(Icons.receipt_long_outlined),
          title: Text(item.id),
          subtitle: Text(item.status),
        );
      },
    );
  }
}
