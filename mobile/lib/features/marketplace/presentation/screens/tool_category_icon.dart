import 'package:flutter/material.dart';

/// Maps a tool category to a representative icon (P10.2).
IconData toolCategoryIcon(String category) => switch (category) {
  'Power Tools' => Icons.handyman,
  'Access' => Icons.construction,
  'Safety Gear' => Icons.health_and_safety_outlined,
  'Electrical' => Icons.electrical_services,
  'Plumbing' => Icons.plumbing,
  'Cleaning' => Icons.cleaning_services_outlined,
  _ => Icons.build_outlined,
};
