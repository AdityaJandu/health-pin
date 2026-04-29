import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';

class EnhancedSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final int? resultCount;

  const EnhancedSearchBar({
    super.key,
    required this.onChanged,
    this.resultCount,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.search_rounded,
              color: AppTheme.primaryDeepForest,
              size: 22,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: 'Search resources, type, location…',
                hintStyle: TextStyle(
                  color: AppTheme.textCharcoal.withAlpha(100),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppTheme.textCharcoal.withAlpha(100),
              onPressed: () {
                setState(() {
                  _controller.clear();
                  widget.onChanged('');
                });
              },
            ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryDeepForest.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppTheme.primaryDeepForest,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
