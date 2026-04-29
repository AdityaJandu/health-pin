import 'package:flutter/material.dart';

class ResourceUtils {
  static String formatTypeName(String name) {
    if (name.isEmpty) return name;
    final spaced = name
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .trim();
    return '${spaced[0].toUpperCase()}${spaced.substring(1).toLowerCase()}';
  }

  /// Returns true/false/null (null = can't determine).
  static bool? isCurrentlyOpen(String? hours) {
    if (hours == null || hours.isEmpty) return null;
    final lower = hours.toLowerCase();
    if (lower.contains('24') || lower.contains('always')) return true;
    if (lower.contains('closed')) return false;

    try {
      final now = TimeOfDay.now();
      final rangeMatch = RegExp(
        r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\s*[–\-]\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)',
        caseSensitive: false,
      ).firstMatch(lower);
      if (rangeMatch == null) return null;

      int toMinutes(int h, int m, String? meridiem) {
        int hour = h;
        if (meridiem != null) {
          if (meridiem == 'pm' && hour != 12) hour += 12;
          if (meridiem == 'am' && hour == 12) hour = 0;
        }
        return hour * 60 + m;
      }

      final openMin = toMinutes(
        int.parse(rangeMatch.group(1)!),
        int.tryParse(rangeMatch.group(2) ?? '') ?? 0,
        rangeMatch.group(3)?.toLowerCase(),
      );
      final closeMin = toMinutes(
        int.parse(rangeMatch.group(4)!),
        int.tryParse(rangeMatch.group(5) ?? '') ?? 0,
        rangeMatch.group(6)?.toLowerCase(),
      );
      final nowMin = now.hour * 60 + now.minute;
      return nowMin >= openMin && nowMin < closeMin;
    } catch (_) {
      return null;
    }
  }
}
