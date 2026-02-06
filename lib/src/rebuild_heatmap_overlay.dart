import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'rebuild_stats.dart';

/// A heatmap overlay that draws colored borders around tracked widgets
/// based on their rebuild count.
///
/// Add this to your app's overlay (e.g., inside [RebuildInspectorOverlay])
/// to visualize rebuild hotspots on screen.
///
/// Only renders in debug mode.
///
/// ```dart
/// Stack(
///   children: [
///     YourApp(),
///     RebuildHeatmapOverlay(),
///   ],
/// )
/// ```
class RebuildHeatmapOverlay extends StatelessWidget {
  const RebuildHeatmapOverlay({
    super.key,
    this.borderWidth = 2,
    this.opacity = 0.6,
  });

  /// Width of the heatmap border around each widget.
  final double borderWidth;

  /// Opacity of the heatmap overlay (0.0 to 1.0).
  final double opacity;

  Color _colorForCount(int count) {
    if (count < 5) return Colors.green;
    if (count < 20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: ValueListenableBuilder<int>(
        valueListenable: RebuildStats.instance.updateNotifier,
        builder: (context, _, __) {
          final entries = RebuildStats.instance.getHeatmapEntries();
          if (entries.isEmpty) return const SizedBox.shrink();

          return CustomPaint(
            painter: _HeatmapPainter(
              entries: entries,
              borderWidth: borderWidth,
              opacity: opacity,
              colorForCount: _colorForCount,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.entries,
    required this.borderWidth,
    required this.opacity,
    required this.colorForCount,
  });

  final List<HeatmapEntry> entries;
  final double borderWidth;
  final double opacity;
  final Color Function(int) colorForCount;

  @override
  void paint(Canvas canvas, Size size) {
    for (final entry in entries) {
      final color = colorForCount(entry.buildCount).withValues(alpha: opacity);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      final rect = entry.rect.inflate(borderWidth / 2);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}
