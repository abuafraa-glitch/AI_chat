import 'package:ai_chat/core/widgets/app_scaffold.dart';
import 'package:ai_chat/core/widgets/empty_state.dart';
import 'package:ai_chat/core/widgets/error_view.dart';
import 'package:ai_chat/core/widgets/loaders/loading_indicator.dart';
import 'package:ai_chat/data/models/subscription_plan_model.dart';
import 'package:ai_chat/presentation/blocs/data_sources.dart';
import 'package:ai_chat/presentation/blocs/subscriptions_cubit.dart';
import 'package:ai_chat/presentation/widgets/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const Color _subscriptionBlue = Color(0xFF159DF5);
const Color _subscriptionPurple = Color(0xFF8B45F2);

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<SubscriptionsCubit>(
        create: (_) =>
            SubscriptionsCubit(repository: buildSubscriptionRepository())..load(),
        child: const _SubscriptionView(),
      );
}

class _SubscriptionView extends StatelessWidget {
  const _SubscriptionView();

  static const _background = Color(0xFF06132E);
  static const _surface = Color(0xFF0D1D3B);
  static const _muted = Color(0xFF9CAAC9);
  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubscriptionsCubit>().state;
    final plans = state.plans;
    final theme = Theme.of(context);
    final cubit = context.read<SubscriptionsCubit>();

    return Theme(
      data: theme.copyWith(scaffoldBackgroundColor: _background),
      child: AppScaffold(
        appBar: AppBar(
          backgroundColor: _background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const _BrandMark(),
          centerTitle: false,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              tooltip: localizedText(context, 'Current subscription', 'الاشتراك الحالي'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CurrentSubscriptionScreen()),
              ),
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(localizedText(context, 'Subscription', 'الاشتراك'), style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(localizedText(context, 'Choose the plan that suits you', 'اختر الخطة المناسبة لك'), style: theme.textTheme.bodyMedium?.copyWith(color: _muted)),
                const SizedBox(height: 24),
                const _BillingSelector(),
                const SizedBox(height: 28),
                if (state.isLoading && plans.isEmpty)
                  const SizedBox(height: 240, child: Center(child: LoadingIndicator()))
                else if (state.error != null && plans.isEmpty)
                  SizedBox(height: 240, child: ErrorView(description: state.error, onRetry: cubit.load))
                else if (plans.isEmpty)
                  SizedBox(
                    height: 240,
                    child: EmptyState(
                      variant: EmptyStateVariant.custom,
                      icon: Icons.workspace_premium_outlined,
                      title: localizedText(context, 'No plans available', 'لا توجد خطط متاحة'),
                      description: localizedText(context, 'Plans will appear when returned by the backend.', 'ستظهر الخطط عند إرجاعها من الخادم.'),
                    ),
                  )
                else
                  SizedBox(
                    height: 500,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      itemCount: plans.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => _PlanCard(
                        plan: plans[index],
                        highlighted: index == plans.length ~/ 2,
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                const _SecurityBanner(),
                const SizedBox(height: 18),
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.help_outline_rounded),
                  label: Text(localizedText(context, 'Have a discount code?', 'لديك كوبون خصم؟')),
                  style: TextButton.styleFrom(foregroundColor: _subscriptionBlue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text('AI', style: TextStyle(color: Colors.purpleAccent, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(width: 6),
        Text('هجين', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(width: 34, height: 34, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF22B8FF), width: 1.5)), child: const Icon(Icons.psychology_outlined, color: Color(0xFF22B8FF), size: 22)),
      ]);
}

class _BillingSelector extends StatelessWidget {
  const _BillingSelector();
  @override
  Widget build(BuildContext context) => Container(
        height: 58,
        decoration: BoxDecoration(color: const Color(0xFF0B1A37), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF22365E))),
        child: Row(children: <Widget>[
          Expanded(child: _SelectorSlot(active: true, label: localizedText(context, 'Monthly', ''))),
          Expanded(child: _SelectorSlot(label: localizedText(context, 'Yearly', ''))),
        ]),
      );
}

class _SelectorSlot extends StatelessWidget {
  const _SelectorSlot({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(4),
        decoration: active ? BoxDecoration(borderRadius: BorderRadius.circular(17), gradient: const LinearGradient(colors: [_subscriptionBlue, _subscriptionPurple])) : null,
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFFB6C2DE), fontSize: 16, fontWeight: FontWeight.w600)),
      );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.highlighted});
  final SubscriptionPlanModel plan;
  final bool highlighted;
  @override
  Widget build(BuildContext context) {
    final border = highlighted ? const LinearGradient(colors: [_subscriptionBlue, _subscriptionPurple]) : null;
    final child = Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF0A1A37), borderRadius: BorderRadius.circular(25), border: Border.all(color: highlighted ? Colors.transparent : const Color(0xFF22365E), width: 1.5)),
      child: Column(children: <Widget>[
        if (highlighted) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF263967), borderRadius: BorderRadius.circular(18)), child: const SizedBox(height: 10, width: 65)),
        const SizedBox(height: 18),
        const Icon(Icons.workspace_premium_outlined, color: _subscriptionBlue, size: 48),
        const SizedBox(height: 16),
        Text(plan.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        if (plan.description.isNotEmpty) Text(plan.description, style: const TextStyle(color: Color(0xFF9CAAC9)), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 16),
        Text(plan.price == null ? localizedText(context, 'Price unavailable', 'السعر غير متاح') : '${plan.price} ${plan.currency ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        const Divider(height: 28, color: Color(0xFF25375B)),
        ...plan.features.map(
          (feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: <Widget>[
                const Icon(Icons.check_circle_outline, color: _subscriptionBlue, size: 21),
                const SizedBox(width: 8),
                Expanded(child: Text(feature, style: const TextStyle(color: Colors.white70))),
              ],
            ),
          ),
        ),
      ]),
    );
    return border == null ? child : DecoratedBox(decoration: BoxDecoration(gradient: border, borderRadius: BorderRadius.circular(27)), child: Padding(padding: const EdgeInsets.all(2), child: child));
  }
}

class _BlankLine extends StatelessWidget {
  const _BlankLine({this.width = double.infinity, required this.height});
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.center, child: Container(width: width, height: height, decoration: BoxDecoration(color: const Color(0xFF1A2D52), borderRadius: BorderRadius.circular(8))));
}

class _SecurityBanner extends StatelessWidget {
  const _SecurityBanner();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF0A1B39), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF22365E))), child: Row(children: <Widget>[const Icon(Icons.verified_user_outlined, color: Color(0xFFB5C0D8), size: 32), const SizedBox(width: 12), Expanded(child: Text(localizedText(context, 'Secure and private', 'آمن وخصوصي'), style: const TextStyle(color: Color(0xFFB5C0D8), fontSize: 15)))]));
}

class CurrentSubscriptionScreen extends StatelessWidget {
  const CurrentSubscriptionScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(appBar: AppBar(title: Text(localizedText(context, 'Current subscription', 'الاشتراك الحالي'))), body: Center(child: Text(localizedText(context, 'No subscription data is currently available', 'لا توجد بيانات اشتراك متاحة حاليًا'))));
}
