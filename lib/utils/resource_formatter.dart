import 'package:flutter/material.dart';

class ResourceFormatter {
  static String formatTypeName(String name) {
    if (name.isEmpty) return name;
    final spaced = name
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .trim();
    return '${spaced[0].toUpperCase()}${spaced.substring(1).toLowerCase()}';
  }

  static String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static bool? isOpen(String? hours) {
    if (hours == null || hours.isEmpty) return null;
    final lower = hours.toLowerCase();
    if (lower.contains('24') || lower.contains('always')) return true;
    if (lower.contains('closed')) return false;
    try {
      final now = TimeOfDay.now();
      final m = RegExp(
        r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\s*[–\-]\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)',
        caseSensitive: false,
      ).firstMatch(lower);
      if (m == null) return null;
      
      int toMin(int h, int min, String? mer) {
        if (mer == 'pm' && h != 12) h += 12;
        if (mer == 'am' && h == 12) h = 0;
        return h * 60 + min;
      }

      final open = toMin(
        int.parse(m.group(1)!),
        int.tryParse(m.group(2) ?? '') ?? 0,
        m.group(3)?.toLowerCase(),
      );
      final close = toMin(
        int.parse(m.group(4)!),
        int.tryParse(m.group(5) ?? '') ?? 0,
        m.group(6)?.toLowerCase(),
      );
      final nowMin = now.hour * 60 + now.minute;
      return nowMin >= open && nowMin < close;
    } catch (_) {
      return null;
    }
  }
}
