import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/components/health_card.dart';

class ResourceSearchBar extends StatelessWidget {
  const ResourceSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: HealthCard(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppTheme.textCharcoal),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search for health resources...',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    filled: false,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Icon(Icons.filter_list, color: AppTheme.textCharcoal),
            ],
          ),
        ),
      ),
    );
  }
}
