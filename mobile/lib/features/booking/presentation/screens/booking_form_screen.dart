import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/provider_avatar.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../discovery/data/models/catalog_models.dart';
import '../../../discovery/data/models/provider_models.dart';
import '../../../discovery/presentation/providers/discovery_providers.dart';
import '../../data/booking_repository.dart';
import '../../data/models/booking_models.dart';

/// Booking form (P4.8, mockup image32): choose the service, schedule, describe
/// the task and confirm — with a live, transparent price breakdown that updates
/// as you change the hours or add your location.
class BookingFormScreen extends ConsumerStatefulWidget {
  const BookingFormScreen({super.key, required this.providerId, this.skillId});

  final String providerId;
  final String? skillId;

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  static const _minHours = 0.5;
  static const _maxHours = 24.0;
  static const _step = 0.5;

  String? _selectedSkillId;
  DateTime? _scheduledAt;
  double _hours = 2.0;

  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  PricingBreakdown? _quote;
  bool _quoting = false;
  Timer? _debounce;

  bool _submitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _selectedSkillId = widget.skillId;
    // Prefill contact from the signed-in customer.
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      _phoneCtrl.text = user.phone;
    }
    _refreshQuote();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  double? _parseCoord(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : double.tryParse(t);
  }

  void _scheduleQuote() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _refreshQuote);
  }

  Future<void> _refreshQuote() async {
    setState(() => _quoting = true);
    try {
      final q = await ref
          .read(bookingRepositoryProvider)
          .quote(
            providerId: widget.providerId,
            estimatedHours: _hours,
            latitude: _parseCoord(_latCtrl),
            longitude: _parseCoord(_lngCtrl),
          );
      if (mounted) setState(() => _quote = q);
    } catch (_) {
      // A failed estimate shouldn't block the form; the final price is
      // computed server-side on submit anyway.
      if (mounted) setState(() => _quote = null);
    } finally {
      if (mounted) setState(() => _quoting = false);
    }
  }

  void _setHours(double v) {
    final clamped = v.clamp(_minHours, _maxHours).toDouble();
    if (clamped == _hours) return;
    setState(() => _hours = clamped);
    _refreshQuote();
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _scheduledAt ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _formError = null;
    });
  }

  Future<void> _submit(List<Skill> skills) async {
    final skillId = _effectiveSkillId(skills);
    if (skillId == null) {
      setState(() => _formError = 'Please choose a service.');
      return;
    }
    if (_scheduledAt == null) {
      setState(() => _formError = 'Please pick a date and time.');
      return;
    }
    if (_scheduledAt!.isBefore(DateTime.now())) {
      setState(() => _formError = 'Choose a time in the future.');
      return;
    }
    setState(() {
      _submitting = true;
      _formError = null;
    });
    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .createBooking(
            providerId: widget.providerId,
            skillId: skillId,
            scheduledAt: _scheduledAt!,
            estimatedHours: _hours,
            addressLine: _addressCtrl.text,
            latitude: _parseCoord(_latCtrl),
            longitude: _parseCoord(_lngCtrl),
            taskTitle: _titleCtrl.text,
            description: _descCtrl.text,
            contactName: _nameCtrl.text,
            contactPhone: _phoneCtrl.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request sent to the provider.')),
      );
      // Land on the booking detail / status timeline for the new job.
      context.pushReplacement('/booking/${booking.id}');
    } catch (e) {
      if (mounted) {
        setState(() => _formError = e.toString());
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _effectiveSkillId(List<Skill> skills) {
    if (skills.isEmpty) return null;
    final ids = skills.map((s) => s.id).toSet();
    if (_selectedSkillId != null && ids.contains(_selectedSkillId)) {
      return _selectedSkillId;
    }
    return skills.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(providerDetailProvider(widget.providerId));
    return Scaffold(
      body: detail.when(
        loading: () => _scaffoldWithHeader(
          null,
          const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        error: (e, _) => _scaffoldWithHeader(null, _error(e.toString())),
        data: (p) => _scaffoldWithHeader(p, _form(p)),
      ),
      bottomNavigationBar: detail.maybeWhen(
        data: (p) => _confirmBar(p),
        orElse: () => null,
      ),
    );
  }

  Widget _scaffoldWithHeader(ProviderDetail? p, Widget body) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_header(p), body],
      ),
    );
  }

  Widget _header(ProviderDetail? p) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Text(
                    'Request a booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (p != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 0, 0),
                  child: Row(
                    children: [
                      ProviderAvatar(
                        name: p.fullName,
                        imageUrl: p.avatarUrl,
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RatingStars(
                              rating: p.avgRating,
                              count: p.ratingCount,
                              size: 13,
                              showValue: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () =>
                            context.push('/home/provider/${widget.providerId}'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('View Profile'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(ProviderDetail p) {
    final skills = p.skills;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Service'),
          const SizedBox(height: 10),
          if (skills.isEmpty)
            _note('This provider has no bookable services yet.')
          else
            DropdownButtonFormField<String>(
              initialValue: _effectiveSkillId(skills),
              items: [
                for (final s in skills)
                  DropdownMenuItem(value: s.id, child: Text(s.name)),
              ],
              onChanged: (v) => setState(() => _selectedSkillId = v),
              decoration: const InputDecoration(hintText: 'Choose a service'),
            ),
          const SizedBox(height: 20),

          _sectionTitle('When'),
          const SizedBox(height: 10),
          _scheduleField(),
          const SizedBox(height: 12),
          _hoursStepper(),
          const SizedBox(height: 20),

          _sectionTitle('Where'),
          const SizedBox(height: 10),
          TextField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              hintText: 'Address / landmark (optional)',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add your location to include an accurate travel fee.',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _coordField(_latCtrl, 'Latitude')),
              const SizedBox(width: 12),
              Expanded(child: _coordField(_lngCtrl, 'Longitude')),
            ],
          ),
          const SizedBox(height: 20),

          _sectionTitle('Task details'),
          const SizedBox(height: 10),
          TextField(
            controller: _titleCtrl,
            maxLength: 150,
            decoration: const InputDecoration(
              hintText: 'Short title (e.g. Fix kitchen sink)',
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Describe what you need (optional)…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),

          _sectionTitle('Contact'),
          const SizedBox(height: 10),
          TextField(
            controller: _nameCtrl,
            maxLength: 120,
            decoration: const InputDecoration(
              hintText: 'Contact name',
              prefixIcon: Icon(Icons.person_outline),
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 30,
            decoration: const InputDecoration(
              hintText: 'Contact phone',
              prefixIcon: Icon(Icons.phone_outlined),
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Price estimate'),
          const SizedBox(height: 10),
          _priceCard(),
          if (_formError != null) ...[
            const SizedBox(height: 12),
            Text(_formError!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _scheduleField() {
    final has = _scheduledAt != null;
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusField),
      onTap: _pickSchedule,
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(
          has ? _fmtDateTime(_scheduledAt!) : 'Select date & time',
          style: TextStyle(
            color: has ? AppColors.textBody : AppColors.textMuted,
            fontWeight: has ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _hoursStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
      ),
      child: Row(
        children: [
          const Icon(Icons.timelapse_outlined, color: AppColors.textMuted),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Estimated hours',
              style: TextStyle(color: AppColors.textBody),
            ),
          ),
          _roundBtn(Icons.remove, () => _setHours(_hours - _step)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _fmtHours(_hours),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _roundBtn(Icons.add, () => _setHours(_hours + _step)),
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _coordField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
      onChanged: (_) => _scheduleQuote(),
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _priceCard() {
    final q = _quote;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: q == null
          ? Row(
              children: [
                if (_quoting)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _quoting
                        ? 'Calculating estimate…'
                        : 'Estimate unavailable — final price is confirmed on booking.',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _priceRow('Base fee', _rs(q.basePrice)),
                const SizedBox(height: 8),
                _priceRow(
                  'Work fee (${_fmtHours(q.workingHours)} × ${_rs(q.hourlyRate)})',
                  _rs(q.workingFee),
                ),
                const SizedBox(height: 8),
                _priceRow(
                  q.travelDistanceKm > 0
                      ? 'Travel (${q.travelDistanceKm.toStringAsFixed(1)} km)'
                      : 'Travel',
                  _rs(q.travelFee),
                  muted: q.travelFee == 0,
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        if (_quoting)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        Text(
                          _rs(q.totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _priceRow(String label, String value, {bool muted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: muted ? AppColors.textMuted : AppColors.textBody,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: muted ? AppColors.textMuted : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _confirmBar(ProviderDetail p) {
    final total = _quote?.totalPrice;
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
                  const Text(
                    'Estimated total',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  Text(
                    total == null ? '—' : _rs(total),
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
                onPressed: (_submitting || p.skills.isEmpty)
                    ? null
                    : () => _submit(p.skills),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Confirm booking'),
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

  Widget _note(String text) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surfaceBlue.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppTheme.radiusField),
    ),
    child: Text(text, style: const TextStyle(color: AppColors.textBody)),
  );

  Widget _error(String msg) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
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
          child: const Text('Go back'),
        ),
      ],
    ),
  );

  // --- formatting helpers (no intl dependency) ---
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _rs(double v) => 'Rs. ${v.toStringAsFixed(0)}';

  String _fmtHours(double h) =>
      h == h.roundToDouble() ? '${h.toInt()} h' : '${h.toStringAsFixed(1)} h';

  String _fmtDateTime(DateTime dt) {
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${_months[dt.month - 1]} ${dt.day}, ${dt.year} · $h12:$mm $ampm';
  }
}
