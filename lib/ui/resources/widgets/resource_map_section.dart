import 'package:flutter/material.dart';
import 'package:healthpin/ui/resources/widgets/resource_info_cards.dart';

class ResourceMapSection extends StatelessWidget {
  final double latitude;
  final double longitude;
  final Color color;

  const ResourceMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            icon: Icons.map_rounded,
            label: 'LOCATION',
            color: color,
          ),
          const SizedBox(height: 10),
          _MapPlaceholder(
            latitude: latitude,
            longitude: longitude,
            color: color,
          ),
        ],
      ),
    );
  }
}

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
