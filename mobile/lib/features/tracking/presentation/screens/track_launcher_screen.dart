import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// Interim Tasks tab: until Phase B adds a real bookings list, this lets you
/// open live tracking for a job by id (e.g. one created via the consent API).
class TrackLauncherScreen extends StatefulWidget {
  const TrackLauncherScreen({super.key});

  @override
  State<TrackLauncherScreen> createState() => _TrackLauncherScreenState();
}

class _TrackLauncherScreenState extends State<TrackLauncherScreen> {
  final _jobCtrl = TextEditingController();
  final _latCtrl = TextEditingController(text: '6.8500');
  final _lngCtrl = TextEditingController(text: '79.8600');

  @override
  void dispose() {
    _jobCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  void _track() {
    final jobId = _jobCtrl.text.trim();
    if (jobId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a job id to track')));
      return;
    }
    final params = <String, String>{};
    if (_latCtrl.text.trim().isNotEmpty)
      params['destLat'] = _latCtrl.text.trim();
    if (_lngCtrl.text.trim().isNotEmpty)
      params['destLng'] = _lngCtrl.text.trim();
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    context.push('/track/$jobId${query.isEmpty ? '' : '?$query'}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceBlue.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Your bookings list arrives in the next phase. For now you can open '
                'live tracking for a job by its id.',
                style: TextStyle(color: AppColors.textBody),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Track a job',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _jobCtrl,
              decoration: const InputDecoration(hintText: 'Job id (UUID)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Destination lat',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lngCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Destination lng',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _track,
              icon: const Icon(Icons.my_location),
              label: const Text('Track provider'),
            ),
          ],
        ),
      ),
    );
  }
}
