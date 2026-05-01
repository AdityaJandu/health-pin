import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/utils/resource_formatter.dart';
import 'package:healthpin/ui/resources/widgets/resource_details_header.dart';
import 'package:healthpin/ui/resources/widgets/resource_info_cards.dart';
import 'package:healthpin/ui/resources/widgets/resource_map_section.dart';
import 'package:healthpin/ui/resources/widgets/resource_bottom_bar.dart';

class ResourceScreen extends StatefulWidget {
  final ResourceModel resourceModel;
  const ResourceScreen({super.key, required this.resourceModel});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  ResourceModel get r => widget.resourceModel;
  bool _upvoted = false;
  late int _upvoteCount;

  final ResourceService _resourceService = ResourceService();

  @override
  void initState() {
    super.initState();
    _upvoteCount = r.upvoteCount;
  }

  void _toggleUpvote() {
    if (r.id == null) return;

    HapticFeedback.lightImpact();

    final newUpvoted = !_upvoted;
    final newCount = _upvoteCount + (newUpvoted ? 1 : -1);

    setState(() {
      _upvoted = newUpvoted;
      _upvoteCount = newCount;
    });

    _resourceService.updateResourceField(r.id!, 'upvote_count', newCount);
  }

  @override
  Widget build(BuildContext context) {
    final color = r.type.color;
    final icon = r.type.icon;
    final openStatus = ResourceFormatter.isOpen(r.openingHours);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWarmOffWhite,
      body: CustomScrollView(
        slivers: [
          // ── Collapsible Photo Header ────────────────────────────────
          ResourceDetailsHeader(
            name: r.name,
            photoUrl: r.photoUrl,
            color: color,
            icon: icon,
          ),

          // ── Name + Badges Card ──────────────────────────────────────
          SliverToBoxAdapter(
            child: ResourceNameCard(
              resource: r,
              typeName: ResourceFormatter.formatTypeName(r.type.name),
              openStatus: openStatus,
              upvoteCount: _upvoteCount,
              upvoted: _upvoted,
            ),
          ),

          // ── Details Card ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ResourceDetailsSection(resource: r, openStatus: openStatus),
          ),

          // ── Description Card ────────────────────────────────────────
          SliverToBoxAdapter(child: ResourceDescriptionSection(resource: r)),

          // ── Map Card ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ResourceMapSection(
              latitude: r.latitude,
              longitude: r.longitude,
              color: color,
            ),
          ),

          // ── Meta Card ───────────────────────────────────────────────
          SliverToBoxAdapter(child: ResourceMetaSection(resource: r)),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── Bottom Action Bar ───────────────────────────────────────────
      bottomNavigationBar: ResourceBottomBar(
        color: color,
        upvoted: _upvoted,
        upvoteCount: _upvoteCount,
        onUpvote: _toggleUpvote,
        long: r.longitude,
        lat: r.latitude,
      ),
    );
  }
}
