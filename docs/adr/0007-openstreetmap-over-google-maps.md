# ADR-0007: OpenStreetMap (flutter_map) for live tracking, not Google Maps

- **Status:** Accepted
- **Date:** 2026-08-16

## Context
The live-tracking screen needs a real, interactive map showing the provider's moving
position and the destination. `google_maps_flutter` is the default choice but requires
a billing-enabled API key plus native (Android/iOS) configuration — neither of which
we had, per ADR-0001. The map had been a placeholder as a result.

## Decision
Use **`flutter_map` with OpenStreetMap raster tiles**, which needs **no API key and no
billing**. It renders the provider's live-moving marker (fed by the existing STOMP
location stream) and the destination, with OSM attribution. The provider-location and
Haversine-ETA logic are unchanged — only the visual layer.

## Alternatives considered
- **Google Maps** — better routing/tiles, but blocked on keys/billing and native
  setup; deferred as an optional swap.
- **Keep the placeholder** — leaves a visible gap in a headline feature.

## Consequences
- A genuine live map with zero credentials, honouring the no-keys constraint.
- OSM's public tile server suits demo/portfolio use; production traffic should point
  `TileLayer` at a dedicated tile provider (or swap in Google Maps) per OSM's usage
  policy. The tile layer is the only thing that changes.
