import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/provider_models.dart';
import '../providers/discovery_providers.dart';
import '../widgets/provider_card_tile.dart';

/// Provider list for a category (with skill filter chips) or a free-text
/// search, aligned to the Figma: a navy breadcrumb header + search toolbar over
/// light-blue provider cards. A map toggle keeps the nearby-providers view.
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
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _searchCtrl.text = _query;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String? _effectiveQuery() {
    final q = _query.trim();
    return q.isEmpty ? null : q;
  }

  @override
  Widget build(BuildContext context) {
    final query = ProviderQuery(
      categoryId: widget.categoryId,
      skillId: _skillId,
      query: _effectiveQuery(),
    );
    final results = ref.watch(providerSearchProvider(query));

    return Scaffold(
      body: Column(
        children: [
          _header(),
          if (widget.categoryId != null) _skillChips(widget.categoryId!),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _error(
                e.toString(),
                () => ref.invalidate(providerSearchProvider(query)),
              ),
              data: (list) {
                if (list.isEmpty) return _empty();
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
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final p = list[i];
                      return ProviderCardTile(
                        provider: p,
                        onTap: () => context.push('/home/provider/${p.id}'),
                        onBook: () => context.push('/book/${p.id}'),
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

  Widget _header() {
    final l = AppLocalizations.of(context);
    final crumb = widget.categoryName != null
        ? '${l.serviceCategories} › ${widget.categoryName}'
        : (widget.initialQuery != null
              ? l.discoveryResultsFor(widget.initialQuery!)
              : l.discoveryProviders);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (context.canPop())
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    )
                  else
                    const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      crumb,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => context.go('/profile'),
                    borderRadius: BorderRadius.circular(24),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    _circleBtn(
                      Icons.search,
                      () => setState(() => _query = _searchCtrl.text.trim()),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _searchField()),
                    const SizedBox(width: 10),
                    _squareBtn(
                      _mapView ? Icons.view_list_rounded : Icons.map_outlined,
                      () => setState(() => _mapView = !_mapView),
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

  Widget _searchField() {
    return TextField(
      controller: _searchCtrl,
      textInputAction: TextInputAction.search,
      onSubmitted: (v) => setState(() => _query = v.trim()),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: AppLocalizations.of(context).searchHint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        height: 46,
        width: 46,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _squareBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 46,
        width: 46,
        decoration: BoxDecoration(
          color: AppColors.surfaceBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
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
                AppLocalizations.of(context).commonAll,
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
    children: [
      const SizedBox(height: 80),
      const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
      const SizedBox(height: 12),
      Center(
        child: Text(
          AppLocalizations.of(context).discoveryNoProviders,
          style: const TextStyle(color: AppColors.textMuted),
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
          OutlinedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).commonRetry),
          ),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppLocalizations.of(context).discoveryNoLocations,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final avgLat =
        located.map((p) => p.latitude!).reduce((a, b) => a + b) /
        located.length;
    final avgLng =
        located.map((p) => p.longitude!).reduce((a, b) => a + b) /
        located.length;

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
