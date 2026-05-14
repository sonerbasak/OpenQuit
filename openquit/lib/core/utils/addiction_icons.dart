import 'package:flutter/material.dart';

/// Maps icon name strings (stored in the domain entity) to Flutter [IconData].
///
/// Keeping this mapping in core/utils means the domain layer stays
/// completely UI-agnostic — it only stores a plain string like "smoking".
abstract final class AddictionIcons {
  static const Map<String, IconData> _map = {
    'smoking': Icons.smoking_rooms_rounded,
    'alcohol': Icons.local_bar_rounded,
    'gambling': Icons.casino_rounded,
    'social_media': Icons.phone_android_rounded,
    'sugar': Icons.cake_rounded,
    'coffee': Icons.coffee_rounded,
    'gaming': Icons.sports_esports_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'drugs': Icons.medication_rounded,
    'porn': Icons.block_rounded,
    'junk_food': Icons.fastfood_rounded,
    'default': Icons.self_improvement_rounded,
  };

  /// Returns the [IconData] for [name], falling back to a default icon.
  static IconData fromName(String name) =>
      _map[name] ?? _map['default']!;

  /// All available icon entries for the picker UI.
  static List<MapEntry<String, IconData>> get all => _map.entries.toList();
}
