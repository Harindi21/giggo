import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/provider_location.dart';
import '../../data/tracking_socket_client.dart';
import '../providers/tracking_providers.dart';

/// Customer live-tracking screen (P5.7 map + P5.8 ETA + P5.9 text fallback).
///
/// Shows a real interactive map (OpenStreetMap via flutter_map — no API key)
/// with the provider's live-moving marker and the destination, plus connection
/// status and a live ETA. Degrades to text gracefully before any location
/// arrives or if the map can't load.
class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({
    super.key,
    required this.jobId,
    this.destLat,
    this.destLng,
  });

  final String jobId;
  final double? destLat;
  final double? destLng;

  bool get _hasDestination => destLat != null && destLng != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(socketStatusProvider).value ?? SocketStatus.connecting;
    final locationAsync = ref.watch(jobLocationProvider(jobId));

    // Refresh the ETA each time a new position arrives.
    if (_hasDestination) {
      ref.listen(jobLocationProvider(jobId), (_, next) {
        if (next.hasValue) {
          ref.invalidate(
            etaProvider((jobId: jobId, destLat: destLat!, destLng: destLng!)),
          );
        }
      });
    }

    final location = locationAsync.value;

    return Scaffold(
      body: Column(
        children: [
          _header(context, status),
          _mapArea(location),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _etaBanner(ref, location),
                  const SizedBox(height: 16),
                  _detailsCard(location),
                ],
              ),
            ),
          ),
          _stopBar(context, ref),
        ],
      ),
    );
  }

  // ---- Header with connection status ----
  Widget _header(BuildContext context, SocketStatus status) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Expanded(
                child: Text(
                  'Live tracking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _statusChip(status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(SocketStatus status) {
    final (label, color) = switch (status) {
      SocketStatus.connected => ('Live', AppColors.success),
      SocketStatus.connecting => ('Connecting…', AppColors.warning),
      SocketStatus.disconnected => ('Reconnecting…', AppColors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Live map (OpenStreetMap via flutter_map; no API key needed) ----
  Widget _mapArea(ProviderLocation? location) {
    // Nothing to plot yet: show a friendly placeholder.
    if (location == null && !_hasDestination) {
      return Container(
        height: 240,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: AppColors.surfaceBlue.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: AppColors.primary),
            SizedBox(height: 10),
            Text(
              'Waiting for the provider to share location…',
              style: TextStyle(
                color: AppColors.textBody,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      height: 240,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: _LiveMap(
        providerLat: location?.latitude,
        providerLng: location?.longitude,
        destLat: destLat,
        destLng: destLng,
      ),
    );
  }

  // ---- ETA banner (P5.8) ----
  Widget _etaBanner(WidgetRef ref, ProviderLocation? location) {
    if (!_hasDestination) {
      return _banner('Set a destination to see the ETA.', Icons.info_outline);
    }
    if (location == null) {
      return _banner('Waiting for the provider location…', Icons.access_time);
    }
    final etaAsync = ref.watch(
      etaProvider((jobId: jobId, destLat: destLat!, destLng: destLng!)),
    );
    return etaAsync.when(
      loading: () => _banner('Estimating arrival…', Icons.access_time),
      error: (_, _) =>
          _banner('ETA unavailable right now.', Icons.error_outline),
      data: (eta) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.directions_car_filled,
              color: AppColors.accent,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${eta.etaMinutes} min away',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${eta.distanceKm.toStringAsFixed(1)} km • arriving to your location',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _banner(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textBody),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Text details (works with no map — P5.9) ----
  Widget _detailsCard(ProviderLocation? location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Provider status',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _detailRow(
            'Position',
            location == null
                ? 'Not shared yet'
                : '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
          ),
          _detailRow(
            'Speed',
            location?.speedKmh == null
                ? '—'
                : '${location!.speedKmh!.toStringAsFixed(0)} km/h',
          ),
          _detailRow(
            'Updated',
            location?.at == null ? '—' : _fmtTime(location!.at!.toLocal()),
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textBody,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stopBar(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('Stop tracking'),
          ),
        ),
      ),
    );
  }
}

/// Interactive live map (OpenStreetMap tiles via flutter_map — no API key).
/// Shows the provider's live-moving marker and the destination, recentring as
/// new positions arrive. For heavy production traffic, point [TileLayer] at your
/// own tile provider per the OSM usage policy.
class _LiveMap extends StatefulWidget {
  const _LiveMap({
    this.providerLat,
    this.providerLng,
    this.destLat,
    this.destLng,
  });

  final double? providerLat;
  final double? providerLng;
  final double? destLat;
  final double? destLng;

  @override
  State<_LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<_LiveMap> {
  final MapController _controller = MapController();

  LatLng? get _provider =>
      (widget.providerLat != null && widget.providerLng != null)
      ? LatLng(widget.providerLat!, widget.providerLng!)
      : null;

  LatLng? get _dest => (widget.destLat != null && widget.destLng != null)
      ? LatLng(widget.destLat!, widget.destLng!)
      : null;

  @override
  void didUpdateWidget(covariant _LiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final p = _provider;
    if (p != null &&
        (oldWidget.providerLat != widget.providerLat ||
            oldWidget.providerLng != widget.providerLng)) {
      _controller.move(p, _controller.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colombo as a neutral fallback centre until a real point is known.
    final center = _provider ?? _dest ?? const LatLng(6.9271, 79.8612);
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(initialCenter: center, initialZoom: 14),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.giggo.mobile',
        ),
        MarkerLayer(
          markers: [
            if (_dest != null)
              Marker(
                point: _dest!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            if (_provider != null)
              Marker(
                point: _provider!,
                width: 44,
                height: 44,
                child: const Icon(
                  Icons.directions_car_filled,
                  color: AppColors.accent,
                  size: 34,
                ),
              ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }
}
