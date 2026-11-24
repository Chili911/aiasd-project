
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String storageKey = 'selected_location';

  static final ValueNotifier<Map<String, dynamic>?> selectedLocation =
      ValueNotifier<Map<String, dynamic>?>(null);

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(storageKey);

    if (saved != null) {
      try {
        selectedLocation.value =
            Map<String, dynamic>.from(jsonDecode(saved));
      } catch (_) {
        await prefs.remove(storageKey);
      }
    }
  }

  static Future<void> selectLocation(
    Map<String, dynamic> location,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(storageKey, jsonEncode(location));
    selectedLocation.value = Map<String, dynamic>.from(location);
  }

  static Map<String, dynamic>? get currentLocation =>
      selectedLocation.value;

  static String get city =>
      currentLocation?['city']?.toString() ?? '';

  static String get country =>
      currentLocation?['country']?.toString() ?? '';

  static double? get latitude =>
      (currentLocation?['latitude'] as num?)?.toDouble();

  static double? get longitude =>
      (currentLocation?['longitude'] as num?)?.toDouble();

  static Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
    selectedLocation.value = null;
  }
}
