import 'package:flutter/material.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/ui/home/widgets/resource_list_item.dart';

class ResourceListView extends StatelessWidget {
  final List<ResourceModel> resources;
  final String Function(ResourceModel) distanceFormatter;
  final void Function(ResourceModel) onResourceTap;

  const ResourceListView({
    super.key,
    required this.resources,
    required this.distanceFormatter,
    required this.onResourceTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return ResourceListItem(
          resource: resource,
          distance: distanceFormatter(resource),
          onTap: () => onResourceTap(resource),
        );
      },
    );
  }
}
