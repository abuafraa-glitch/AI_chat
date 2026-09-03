import 'package:ai_chat/core/widgets/app_scaffold.dart';
import 'package:ai_chat/presentation/widgets/localized_text.dart';
import 'package:flutter/material.dart';

/// UI-only payment screen. It intentionally performs no payment or network call.
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

enum PaymentUiStatus { idle, pending, success, failure, canceled }

class _PaymentsScreenState extends State<PaymentsScreen> {
  PaymentUiStatus status = PaymentUiStatus.idle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      appBar: AppBar(title: Text(localizedText(context, 'Payment', 'الدفع'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _SectionCard(
            title: localizedText(context, 'Selected plan', 'الخطة المختارة'),
            child: _Placeholder(text: localizedText(context, 'Waiting for plan data', 'بانتظار بيانات الخطة')),
          ),
          _SectionCard(
            title: localizedText(context, 'Order summary', 'ملخص العملية'),
            child: Column(
              children: <Widget>[
                _SummaryRow(label: localizedText(context, 'Price', 'السعر'), value: ''),
                _SummaryRow(label: localizedText(context, 'Currency', 'العملة'), value: ''),
                _SummaryRow(label: localizedText(context, 'Billing period', 'مدة الاشتراك'), value: ''),
              ],
            ),
          ),
          _StatusCard(status: status),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: status == PaymentUiStatus.pending ? null : _startPayment,
            icon: const Icon(Icons.lock_outline),
            label: Text(localizedText(context, 'Start payment', 'بدء الدفع')),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: status == PaymentUiStatus.pending ? _cancelPayment : null,
            child: Text(localizedText(context, 'Cancel', 'إلغاء')),
          ),
          const SizedBox(height: 24),
          Text(
            localizedText(context, 'Payment provider data will be supplied later.', 'سيتم توفير بيانات مزود الدفع لاحقًا.'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _startPayment() {
    setState(() => status = PaymentUiStatus.pending);
  }

  void _cancelPayment() {
    setState(() => status = PaymentUiStatus.canceled);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ]),
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: <Widget>[Expanded(child: Text(label)), Text(value)]),
      );
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: Theme.of(context).textTheme.bodyMedium);
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});
  final PaymentUiStatus status;
  @override
  Widget build(BuildContext context) {
    final labels = <PaymentUiStatus, String>{
      PaymentUiStatus.idle: localizedText(context, 'Ready', 'جاهز'),
      PaymentUiStatus.pending: localizedText(context, 'Pending', 'قيد الانتظار'),
      PaymentUiStatus.success: localizedText(context, 'Success', 'نجحت العملية'),
      PaymentUiStatus.failure: localizedText(context, 'Failed', 'فشلت العملية'),
      PaymentUiStatus.canceled: localizedText(context, 'Canceled', 'أُلغيت العملية'),
    };
    return Card(
      child: ListTile(
        leading: Icon(_icon(status)),
        title: Text(localizedText(context, 'Payment status', 'حالة الدفع')),
        subtitle: Text(labels[status] ?? ''),
      ),
    );
  }

  IconData _icon(PaymentUiStatus value) => switch (value) {
        PaymentUiStatus.success => Icons.check_circle_outline,
        PaymentUiStatus.failure => Icons.error_outline,
        PaymentUiStatus.canceled => Icons.cancel_outlined,
        PaymentUiStatus.pending => Icons.hourglass_empty,
        PaymentUiStatus.idle => Icons.info_outline,
      };
}
