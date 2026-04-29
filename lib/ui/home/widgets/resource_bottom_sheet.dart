import 'package:flutter/material.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'resource_list_item.dart';

class ResourceBottomSheet extends StatelessWidget {
  final bool isLoading;
  final List<ResourceModel> resources;
  final String Function(ResourceModel) distanceFormatter;

  const ResourceBottomSheet({
    super.key,
    required this.isLoading,
    required this.resources,
    required this.distanceFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.25,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Pull Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryDeepForest,
                        ),
                      )
                    : resources.isEmpty
                        ? Center(
                            child: Text(
                              'No resources nearby.\nBe the first to add one!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: resources.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    '${resources.length} Nearby Resources',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                );
                              }

                              final resource = resources[index - 1];
                              final distance = distanceFormatter(resource);

                              return ResourceListItem(
                                resource: resource,
                                distance: distance,
                                onTap: () {
                                  // Handle tap
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
