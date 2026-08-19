import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/provider_profile.dart';
import '../../data/provider_profile_repository.dart';
import '../providers/provider_profile_providers.dart';

/// Provider-facing editor for the profile customers search and book (P2.1).
/// Backed by GET/PUT /api/v1/provider/profile.
class ProviderProfileScreen extends ConsumerStatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  ConsumerState<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}

class _ProviderProfileScreenState
    extends ConsumerState<ProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _headlineCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _baseCtrl = TextEditingController();
  final _hourlyCtrl = TextEditingController();

  final _selectedSkillIds = <String>{};
  bool _available = true;
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [
      _headlineCtrl,
      _bioCtrl,
      _experienceCtrl,
      _districtCtrl,
      _addressCtrl,
      _latCtrl,
      _lngCtrl,
      _baseCtrl,
      _hourlyCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefill(ProviderProfile p) {
    _headlineCtrl.text = p.headline ?? '';
    _bioCtrl.text = p.bio ?? '';
    _experienceCtrl.text = p.yearsExperience == 0 ? '' : '${p.yearsExperience}';
    _districtCtrl.text = p.district ?? '';
    _addressCtrl.text = p.addressLine ?? '';
    _latCtrl.text = p.latitude?.toString() ?? '';
    _lngCtrl.text = p.longitude?.toString() ?? '';
    _baseCtrl.text = p.basePrice == 0 ? '' : p.basePrice.toStringAsFixed(0);
    _hourlyCtrl.text = p.hourlyRate == 0 ? '' : p.hourlyRate.toStringAsFixed(0);
    _selectedSkillIds
      ..clear()
      ..addAll(p.skillIds);
    setState(() {
      _available = p.available;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkillIds.isEmpty) {
      setState(() => _error = 'Pick at least one skill so customers can find you.');
      return;
    }
    setState(() => _saving = true);
    try {
      final update = ProviderProfileUpdate(
        headline: _headlineCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        yearsExperience: int.tryParse(_experienceCtrl.text.trim()) ?? 0,
        district: _districtCtrl.text.trim(),
        addressLine: _addressCtrl.text.trim(),
        latitude: _coord(_latCtrl),
        longitude: _coord(_lngCtrl),
        basePrice: double.tryParse(_baseCtrl.text.trim()) ?? 0,
        hourlyRate: double.tryParse(_hourlyCtrl.text.trim()) ?? 0,
        available: _available,
        skillIds: _selectedSkillIds.toList(),
      );
      await ref.read(myProviderProfileRepositoryProvider).updateMyProfile(update);
      ref.invalidate(myProviderProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  double? _coord(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : double.tryParse(t);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(myProviderProfileProvider, (_, next) {
      if (!_loaded) next.whenData(_prefill);
    });
    final profileAsync = ref.watch(myProviderProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My provider profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _errorView(e.toString()),
        data: (profile) => _form(profile),
      ),
      bottomNavigationBar: profileAsync.maybeWhen(
        data: (_) => _saveBar(),
        orElse: () => null,
      ),
    );
  }

  Widget _form(ProviderProfile profile) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _statsCard(profile),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _available,
            onChanged: (v) => setState(() => _available = v),
            title: const Text(
              'Available for new bookings',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Turn off to hide yourself from search while you are busy.',
            ),
            activeThumbColor: AppColors.accent,
          ),
          const Divider(height: 24),
          _label('Headline'),
          TextFormField(
            controller: _headlineCtrl,
            maxLength: 150,
            decoration: const InputDecoration(
              hintText: 'e.g. Trusted plumber, 24/7 in Colombo',
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          _label('About you'),
          TextFormField(
            controller: _bioCtrl,
            maxLength: 1000,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tell customers about your experience and what you offer.',
            ),
          ),
          const SizedBox(height: 8),
          _label('Years of experience'),
          TextFormField(
            controller: _experienceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: 'e.g. 5'),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Where you work'),
          const SizedBox(height: 10),
          _label('District'),
          TextFormField(
            controller: _districtCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'e.g. Colombo'),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Enter your district'
                : null,
          ),
          const SizedBox(height: 16),
          _label('Base address (optional)'),
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              hintText: 'Street / area',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your base location is used to estimate travel fees for customers.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
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
          _sectionTitle('Your rates (LKR)'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _priceField(_baseCtrl, 'Call-out / base', 'Base fee'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _priceField(_hourlyCtrl, 'Hourly rate', 'Hourly rate'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('Skills'),
          const SizedBox(height: 6),
          const Text(
            'Select every service you offer — these power search and matching.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          _skillPicker(),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
        ],
      ),
    );
  }

  Widget _statsCard(ProviderProfile p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      p.verified ? Icons.verified : Icons.verified_outlined,
                      size: 14,
                      color: p.verified ? AppColors.accent : Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      p.verified ? 'KYC verified' : 'Not yet verified',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _stat('${p.avgRating.toStringAsFixed(1)}★', '${p.ratingCount} reviews'),
          const SizedBox(width: 16),
          _stat('${p.jobsCompleted}', 'jobs done'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
    ],
  );

  Widget _skillPicker() {
    final async = ref.watch(catalogSkillsProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const Text(
        'Could not load skills.',
        style: TextStyle(color: AppColors.textMuted),
      ),
      data: (groups) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final g in groups)
            if (g.skills.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  g.category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final s in g.skills)
                    FilterChip(
                      label: Text(s.name),
                      selected: _selectedSkillIds.contains(s.id),
                      onSelected: (sel) => setState(() {
                        if (sel) {
                          _selectedSkillIds.add(s.id);
                        } else {
                          _selectedSkillIds.remove(s.id);
                        }
                      }),
                      selectedColor: AppColors.accent.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.accentDark,
                    ),
                ],
              ),
            ],
        ],
      ),
    );
  }

  Widget _saveBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save profile'),
          ),
        ),
      ),
    );
  }

  Widget _coordField(TextEditingController c, String label) => TextFormField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(
      signed: true,
      decimal: true,
    ),
    decoration: InputDecoration(labelText: label),
    validator: (v) {
      if (v == null || v.trim().isEmpty) return null; // optional
      return double.tryParse(v.trim()) == null ? 'Invalid' : null;
    },
  );

  Widget _priceField(
    TextEditingController c,
    String label,
    String required,
  ) => TextFormField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, prefixText: 'Rs. '),
    validator: (v) {
      final t = (v ?? '').trim();
      if (t.isEmpty) return '$required required';
      final d = double.tryParse(t);
      if (d == null || d < 0) return 'Invalid';
      return null;
    },
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
  );

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
        ],
      ),
    ),
  );
}
