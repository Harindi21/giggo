import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/availability_repository.dart';
import '../../data/models/working_hour.dart';

/// Weekly working-hours editor (P2.10), surfacing GET/PUT /provider/availability.
/// Customers can only book a provider within these hours.
class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _DayConfig {
  bool open;
  TimeOfDay start;
  TimeOfDay end;
  _DayConfig({required this.open, required this.start, required this.end});
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Index 0..6 maps to dayOfWeek 1..7.
  late final List<_DayConfig> _days = List.generate(
    7,
    (_) => _DayConfig(
      open: false,
      start: const TimeOfDay(hour: 9, minute: 0),
      end: const TimeOfDay(hour: 17, minute: 0),
    ),
  );

  bool _loaded = false;
  bool _saving = false;
  String? _error;

  void _prefill(List<WorkingHour> hours) {
    for (final h in hours) {
      final i = h.dayOfWeek - 1;
      if (i >= 0 && i < 7) {
        _days[i]
          ..open = true
          ..start = h.start
          ..end = h.end;
      }
    }
    setState(() => _loaded = true);
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pick(int index, bool isStart) async {
    final current = isStart ? _days[index].start : _days[index].end;
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _days[index].start = picked;
      } else {
        _days[index].end = picked;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _error = null);
    final payload = <WorkingHour>[];
    for (var i = 0; i < 7; i++) {
      final d = _days[i];
      if (!d.open) continue;
      if (_minutes(d.start) >= _minutes(d.end)) {
        setState(
          () => _error = '${_labels[i]}: start time must be before end time.',
        );
        return;
      }
      payload.add(WorkingHour(dayOfWeek: i + 1, start: d.start, end: d.end));
    }
    setState(() => _saving = true);
    try {
      await ref.read(availabilityRepositoryProvider).setMyAvailability(payload);
      ref.invalidate(myAvailabilityProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Working hours saved.')));
      Navigator.of(context).maybePop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(myAvailabilityProvider, (_, next) {
      if (!_loaded) next.whenData(_prefill);
    });
    final async = ref.watch(myAvailabilityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Working hours')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),
        data: (_) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Set the hours you accept bookings. Days left off are treated as '
                'closed. Leave everything off to stay available at any time.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            ),
            for (var i = 0; i < 7; i++) _dayRow(i),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                  : const Text('Save working hours'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayRow(int i) {
    final d = _days[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              _labels[i],
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: d.open,
            activeThumbColor: AppColors.accent,
            onChanged: (v) => setState(() => d.open = v),
          ),
          const Spacer(),
          if (d.open)
            Row(
              children: [
                _timeChip(d.start.format(context), () => _pick(i, true)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '–',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                _timeChip(d.end.format(context), () => _pick(i, false)),
              ],
            )
          else
            const Text('Closed', style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _timeChip(String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    ),
  );
}
