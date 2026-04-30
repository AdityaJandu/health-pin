import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/ui/home/widgets/resource_badges.dart';

class ResourceScreen extends StatefulWidget {
  final ResourceModel resourceModel;
  const ResourceScreen({super.key, required this.resourceModel});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  static const double _expandedHeight = 300.0;

  ResourceModel get r => widget.resourceModel;
  bool _upvoted = false;
  late int _upvoteCount;

  final ResourceService _resourceService = ResourceService();

  @override
  void initState() {
    super.initState();
    _upvoteCount = r.upvoteCount;
  }

  // AFTER — fixed
  void _toggleUpvote() {
    if (r.id == null) return;

    HapticFeedback.lightImpact();

    // Calculate new values first
    final newUpvoted = !_upvoted;
    final newCount = _upvoteCount + (newUpvoted ? 1 : -1);

    setState(() {
      _upvoted = newUpvoted;
      _upvoteCount = newCount;
    });

    _resourceService.updateResourceField(r.id!, 'upvote_count', newCount);
  }

  String _formatTypeName(String name) {
    if (name.isEmpty) return name;
    final spaced = name
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .trim();
    return '${spaced[0].toUpperCase()}${spaced.substring(1).toLowerCase()}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  bool? _isOpen(String? hours) {
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

  @override
  Widget build(BuildContext context) {
    final color = r.type.color;
    final icon = r.type.icon;
    final hasPhoto = r.photoUrl != null && r.photoUrl!.isNotEmpty;
    final openStatus = _isOpen(r.openingHours);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWarmOffWhite,
      body: CustomScrollView(
        slivers: [
          // ── Collapsible Photo Header ────────────────────────────────
          SliverAppBar(
            expandedHeight: _expandedHeight,
            pinned: true,
            backgroundColor: color,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _AppBarButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.maybePop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _AppBarButton(icon: Icons.share_rounded, onTap: () {}),
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final safeArea = MediaQuery.of(context).padding.top;
                final collapsedHeight = kToolbarHeight + safeArea;
                final progress =
                    ((_expandedHeight - constraints.maxHeight) /
                            (_expandedHeight - collapsedHeight))
                        .clamp(0.0, 1.0);
                final titleOpacity = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);

                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  centerTitle: true,
                  title: Opacity(
                    opacity: titleOpacity,
                    child: Text(
                      r.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  background: hasPhoto
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              r.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _PlaceholderBg(color: color, icon: icon),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(170),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        )
                      : _PlaceholderBg(color: color, icon: icon),
                );
              },
            ),
          ),

          // ── Name + Badges Card ──────────────────────────────────────
          SliverToBoxAdapter(
            child: _NameCard(
              resource: r,
              typeName: _formatTypeName(r.type.name),
              openStatus: openStatus,
              upvoteCount: _upvoteCount,
              upvoted: _upvoted,
            ),
          ),

          // ── Details Card ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionCard(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  if (r.address.isNotEmpty)
                    _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Address',
                      value: r.address,
                      color: color,
                    ),
                  if (r.openingHours?.isNotEmpty ?? false) ...[
                    const _RowDivider(),
                    _DetailRow(
                      icon: Icons.access_time_filled_rounded,
                      label: 'Hours',
                      value: r.openingHours!,
                      color: color,
                      trailingWidget: openStatus == null
                          ? null
                          : _InlineStatusDot(isOpen: openStatus),
                    ),
                  ],
                  if (r.contactNumber?.isNotEmpty ?? false) ...[
                    const _RowDivider(),
                    _DetailRow(
                      icon: Icons.phone_rounded,
                      label: 'Contact',
                      value: r.contactNumber!,
                      color: color,
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: r.contactNumber!),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Number copied to clipboard'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: color,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const _RowDivider(),
                  _DetailRow(
                    icon: Icons.my_location_rounded,
                    label: 'Coordinates',
                    value:
                        '${r.latitude.toStringAsFixed(5)}, ${r.longitude.toStringAsFixed(5)}',
                    color: color,
                  ),
                ],
              ),
            ),
          ),

          // ── Description Card ────────────────────────────────────────
          if (r.description.isNotEmpty)
            SliverToBoxAdapter(
              child: _SectionCard(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(
                      icon: Icons.notes_rounded,
                      label: 'ABOUT',
                      color: color,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      r.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textCharcoal.withAlpha(200),
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Map Card ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionCard(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                    icon: Icons.map_rounded,
                    label: 'LOCATION',
                    color: color,
                  ),
                  const SizedBox(height: 10),
                  _MapPlaceholder(
                    latitude: r.latitude,
                    longitude: r.longitude,
                    color: color,
                  ),
                ],
              ),
            ),
          ),

          // ── Meta Card ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionCard(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                    icon: Icons.info_outline_rounded,
                    label: 'INFO',
                    color: color,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        label: 'Added ${_formatDate(r.createdAt)}',
                        icon: Icons.calendar_today_rounded,
                      ),
                      _MetaChip(
                        label: r.isVerified ? 'Verified' : 'Unverified',
                        icon: r.isVerified
                            ? Icons.verified_rounded
                            : Icons.help_outline_rounded,
                        color: r.isVerified
                            ? const Color(0xFF2E7D32)
                            : AppTheme.outline,
                      ),
                    ],
                  ),
                  if (r.submittedBy.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const _RowDivider(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.outline.withAlpha(18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: AppTheme.outline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Submitted by ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.outline,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            r.submittedBy,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textCharcoal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── Bottom Action Bar ───────────────────────────────────────────
      bottomNavigationBar: _BottomBar(
        color: color,
        upvoted: _upvoted,
        upvoteCount: _upvoteCount,
        onUpvote: _toggleUpvote,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP BAR BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(55),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PLACEHOLDER BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceholderBg extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _PlaceholderBg({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDeepForest, color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(12),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(8),
              ),
            ),
          ),
          Center(
            child: Icon(icon, size: 72, color: Colors.white.withAlpha(50)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAME CARD
// ─────────────────────────────────────────────────────────────────────────────

class _NameCard extends StatelessWidget {
  final ResourceModel resource;
  final String typeName;
  final bool? openStatus;
  final int upvoteCount;
  final bool upvoted;

  const _NameCard({
    required this.resource,
    required this.typeName,
    required this.openStatus,
    required this.upvoteCount,
    required this.upvoted,
  });

  @override
  Widget build(BuildContext context) {
    final color = resource.type.color;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + upvote pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  resource.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textCharcoal,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: upvoted
                      ? AppTheme.primaryDeepForest.withAlpha(20)
                      : AppTheme.outline.withAlpha(12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      upvoted
                          ? Icons.thumb_up_alt_rounded
                          : Icons.thumb_up_alt_outlined,
                      size: 13,
                      color: upvoted
                          ? AppTheme.primaryDeepForest
                          : AppTheme.outline.withAlpha(160),
                    ),
                    const SizedBox(width: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Text(
                        '$upvoteCount',
                        key: ValueKey(upvoteCount),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: upvoted
                              ? AppTheme.primaryDeepForest
                              : AppTheme.outline.withAlpha(160),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Badges
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _SmallBadge(
                label: typeName,
                color: color,
                bg: color.withAlpha(22),
                border: color.withAlpha(55),
              ),
              if (resource.isVerified)
                const _SmallBadge(
                  label: 'Verified',
                  icon: Icons.verified_rounded,
                  color: Color(0xFF2E7D32),
                  bg: Color(0x122E7D32),
                  border: Color(0x402E7D32),
                ),
              if (openStatus != null)
                _SmallBadge(
                  label: openStatus! ? 'Open now' : 'Closed',
                  dotColor: openStatus!
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  color: openStatus!
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  bg: openStatus!
                      ? const Color(0xFF2E7D32).withAlpha(18)
                      : const Color(0xFFC62828).withAlpha(18),
                  border: openStatus!
                      ? const Color(0xFF2E7D32).withAlpha(55)
                      : const Color(0xFFC62828).withAlpha(55),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  const _SectionCard({required this.child, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL ROW
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withAlpha(18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.outline,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.textCharcoal,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                        ),
                      ),
                      if (trailingWidget != null) ...[
                        const SizedBox(width: 8),
                        trailingWidget!,
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: color.withAlpha(120),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INLINE STATUS DOT
// ─────────────────────────────────────────────────────────────────────────────

class _InlineStatusDot extends StatelessWidget {
  final bool isOpen;
  const _InlineStatusDot({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROW DIVIDER
// ─────────────────────────────────────────────────────────────────────────────

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 42,
      color: AppTheme.textCharcoal.withAlpha(10),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAP PLACEHOLDER
// ─────────────────────────────────────────────────────────────────────────────

class _MapPlaceholder extends StatelessWidget {
  final double latitude;
  final double longitude;
  final Color color;

  const _MapPlaceholder({
    required this.latitude,
    required this.longitude,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _MapPainter(color: color)),

            // Pin
            Align(
              alignment: const Alignment(0, -0.2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(90),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.place_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 5,
                    decoration: BoxDecoration(
                      color: color.withAlpha(40),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, color.withAlpha(30)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // launch maps
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.open_in_new_rounded,
                              color: Colors.white,
                              size: 11,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Open Maps',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final Color color;
  const _MapPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = color.withAlpha(13),
    );

    final gridPaint = Paint()
      ..color = color.withAlpha(22)
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final center = Offset(size.width / 2, size.height / 2 - 10);
    for (final r in [30.0, 55.0, 80.0, 110.0]) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = color.withAlpha((28 * (1 - r / 120)).round().clamp(4, 28))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// META CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  const _MetaChip({required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withAlpha(40), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: c,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _SmallBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? dotColor;
  final Color color;
  final Color bg;
  final Color border;

  const _SmallBadge({
    required this.label,
    this.icon,
    this.dotColor,
    required this.color,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ] else if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM ACTION BAR
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final Color color;
  final bool upvoted;
  final int upvoteCount;
  final VoidCallback onUpvote;

  const _BottomBar({
    required this.color,
    required this.upvoted,
    required this.upvoteCount,
    required this.onUpvote,
  });

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + safeBottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Upvote button
          GestureDetector(
            onTap: onUpvote,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: upvoted
                    ? AppTheme.primaryDeepForest
                    : AppTheme.primaryDeepForest.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primaryDeepForest.withAlpha(upvoted ? 0 : 50),
                  width: 0.5,
                ),
                boxShadow: upvoted
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryDeepForest.withAlpha(60),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    upvoted
                        ? Icons.thumb_up_alt_rounded
                        : Icons.thumb_up_alt_outlined,
                    size: 18,
                    color: upvoted ? Colors.white : AppTheme.primaryDeepForest,
                  ),
                  const SizedBox(width: 7),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Text(
                      '$upvoteCount',
                      key: ValueKey(upvoteCount),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: upvoted
                            ? Colors.white
                            : AppTheme.primaryDeepForest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Directions button
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: const Text(
                  'Get Directions',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDeepForest,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
