import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/provider_models.dart';
import '../providers/discovery_providers.dart';
import '../widgets/provider_card_tile.dart';

/// Provider list for a category (with skill filter chips) or a free-text search.
class ProviderListScreen extends ConsumerStatefulWidget {
  const ProviderListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.initialQuery,
  });

  final String? categoryId;
  final String? categoryName;
  final String? initialQuery;

  @override
  ConsumerState<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends ConsumerState<ProviderListScreen> {
  String? _skillId;
  bool _mapView = false;

  @override
  Widget build(BuildContext context) {
    final title =
        widget.categoryName ??
        (widget.initialQuery != null
            ? 'Results for "${widget.initialQuery}"'
            : 'Providers');

    final query = ProviderQuery(
      categoryId: widget.categoryId,
      skillId: _skillId,
      query: widget.initialQuery,
    );
    final results = ref.watch(providerSearchProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: _mapView ? 'List view' : 'Map view',
            onPressed: () => setState(() => _mapView = !_mapView),
            icon: Icon(_mapView ? Icons.view_list_outlined : Icons.map_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.categoryId != null) _skillChips(widget.categoryId!),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _error(
                e.toString(),
                () => ref.invalidate(providerSearchProvider(query)),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return _empty();
                }
                if (_mapView) {
                  return _ProvidersMap(
                    providers: list,
                    onTap: (p) => context.push('/home/provider/${p.id}'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(providerSearchProvider(query)),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = list[i];
                      return ProviderCardTile(
                        provider: p,
                        onTap: () => context.push('/home/provider/${p.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillChips(String categoryId) {
    final skills = ref.watch(skillsProvider(categoryId));
    return skills.maybeWhen(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _chip(
                'All',
                _skillId == null,
                () => setState(() => _skillId = null),
              ),
              for (final s in list)
                _chip(
                  s.name,
                  _skillId == s.id,
                  () => setState(() => _skillId = s.id),
                ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.accent,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        backgroundColor: AppColors.surfaceBlue.withValues(alpha: 0.5),
        side: BorderSide.none,
      ),
    );
  }

  Widget _empty() => ListView(
    children: const [
      SizedBox(height: 80),
      Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
      SizedBox(height: 12),
      Center(
        child: Text(
          'No providers found here yet.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      ),
    ],
  );

  Widget _error(String msg, VoidCallback onRetry) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 8),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

/// Nearby-providers map (P3.9): OpenStreetMap markers for providers that have a
/// location; tap a marker to open the provider. No API key needed.
class _ProvidersMap extends StatelessWidget {
  const _ProvidersMap({required this.providers, required this.onTap});

  final List<ProviderCard> providers;
  final void Function(ProviderCard) onTap;

  @override
  Widget build(BuildContext context) {
    final located = providers.where((p) => p.hasLocation).toList();
    if (located.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'None of these providers have shared a location yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    // Centre on the average of the located providers (Colombo as a fallback).
    final avgLat =
        located.map((p) => p.latitude!).reduce((a, b) => a + b) / located.length;
    final avgLng =
        located.map((p) => p.longitude!).reduce((a, b) => a + b) / located.length;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(avgLat, avgLng),
        initialZoom: 11,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.giggo.mobile',
        ),
        MarkerLayer(
          markers: [
            for (final p in located)
              Marker(
                point: LatLng(p.latitude!, p.longitude!),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => onTap(p),
                  child: Icon(
                    Icons.location_on,
                    color: p.available ? AppColors.accent : AppColors.textMuted,
                    size: 40,
                  ),
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
