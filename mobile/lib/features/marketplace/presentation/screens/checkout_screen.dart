import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/models/tool_models.dart';
import '../../data/order_repository.dart';
import '../providers/order_providers.dart';
import '../providers/tool_providers.dart';
import 'tool_category_icon.dart';

/// Tool checkout (P10.4): pick a quantity, add delivery details, place & pay.
/// The gateway is stubbed, so "Place & pay" completes the order immediately.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _qty = 1;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _prefill() {
    if (_prefilled) return;
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      if (_nameCtrl.text.isEmpty) _nameCtrl.text = user.fullName;
      if (_phoneCtrl.text.isEmpty) _phoneCtrl.text = user.phone;
    }
    _prefilled = true;
  }

  Future<void> _submit(Tool tool) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(orderRepositoryProvider);
      final order = await repo.place(
        toolId: tool.id,
        quantity: _qty,
        contactName: _nameCtrl.text.trim(),
        contactPhone: _phoneCtrl.text.trim(),
        shippingAddress: _addressCtrl.text.trim(),
      );
      await repo.pay(order.id); // stubbed gateway capture
      ref.invalidate(myOrdersProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.checkoutOrderPlaced)));
      context.pushReplacement('/orders');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _prefill();
    final async = ref.watch(toolProvider(widget.slug));
    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _errorView(e.toString()),
        data: (tool) => _form(tool),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (tool) => _payBar(tool),
        orElse: () => null,
      ),
    );
  }

  Widget _form(Tool tool) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _toolCard(tool),
                const SizedBox(height: 20),
                _sectionTitle(l.checkoutQuantity),
                const SizedBox(height: 10),
                _qtyStepper(),
                const SizedBox(height: 20),
                _sectionTitle(l.checkoutDelivery),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameCtrl,
                  enabled: !_submitting,
                  maxLength: 120,
                  decoration: InputDecoration(
                    labelText: l.bookingContactName,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneCtrl,
                  enabled: !_submitting,
                  keyboardType: TextInputType.phone,
                  maxLength: 30,
                  decoration: InputDecoration(
                    labelText: l.bookingContactPhone,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressCtrl,
                  enabled: !_submitting,
                  maxLines: 2,
                  maxLength: 400,
                  decoration: InputDecoration(
                    labelText: l.checkoutShippingAddress,
                    counterText: '',
                    alignLabelWithHint: true,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Text(
                l.checkoutTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolCard(Tool tool) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        children: [
          Icon(
            toolCategoryIcon(tool.category),
            color: AppColors.primary,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.checkoutPriceEach(
                    '${l.pricePrefix} ${tool.price.toStringAsFixed(0)}',
                  ),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyStepper() {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.checkoutUnits,
              style: const TextStyle(color: AppColors.textBody),
            ),
          ),
          _roundBtn(Icons.remove, () {
            if (_qty > 1) setState(() => _qty--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$_qty',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _roundBtn(Icons.add, () {
            if (_qty < 99) setState(() => _qty++);
          }),
        ],
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _submitting ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _payBar(Tool tool) {
    final l = AppLocalizations.of(context);
    final total = tool.price * _qty;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.bookingTotal,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '${l.pricePrefix} ${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _submitting ? null : () => _submit(tool),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l.checkoutPlacePay),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
  );

  Widget _errorView(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 8),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(AppLocalizations.of(context).commonGoBack),
          ),
        ],
      ),
    ),
  );
}
