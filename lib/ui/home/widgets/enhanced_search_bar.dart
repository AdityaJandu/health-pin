import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';

class EnhancedSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final int resultCount;

  const EnhancedSearchBar({
    super.key,
    required this.onChanged,
    required this.resultCount,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> {
  final _controller = TextEditingController();
  bool _hasFocus = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _hasFocus = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _hasFocus
                  ? AppTheme.primaryDeepForest.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.18),
              blurRadius: _hasFocus ? 20 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Search clinics, pharmacies…',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _hasFocus
                  ? AppTheme.primaryDeepForest
                  : Colors.grey.shade400,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: Colors.grey.shade400,
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
