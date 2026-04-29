import 'package:flutter/material.dart';
import 'package:healthpin/models/resource_type.dart';
import 'package:healthpin/theme/app_theme.dart';

class ResourceTypeDropdown extends StatelessWidget {
  final ResourceType value;
  final ValueChanged<ResourceType?> onChanged;

  const ResourceTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String _formatTypeName(ResourceType type) {
    return type.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RESOURCE TYPE', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWarmOffWhite,
            borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
            border: Border.all(color: AppTheme.textCharcoal.withAlpha(40)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ResourceType>(
              value: value,
              isExpanded: true,
              items: ResourceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_formatTypeName(type)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
