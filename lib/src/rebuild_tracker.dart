import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'rebuild_stats.dart';

/// Thresholds for rebuild count that determine badge colors.
///
/// - Below [stableThreshold]: Green (stable)
/// - Between [stableThreshold] and [warningThreshold]: Yellow (medium)
/// - Above [warningThreshold]: Red (rebuilding too often)
@immutable
class RebuildThresholds {
  const RebuildThresholds({
    this.stableThreshold = 5,
    this.warningThreshold = 20,
  });

  /// Rebuild count below which the widget is considered "stable" (green).
  final int stableThreshold;

  /// Rebuild count above which the widget is considered "problematic" (red).
  final int warningThreshold;

  /// Default thresholds: green < 5, yellow 5-20, red > 20.
  static const RebuildThresholds defaultThresholds = RebuildThresholds();
}

/// A widget that tracks how many times its [child] rebuilds.
///
/// Wrap any widget you want to monitor for performance issues:
///
/// ```dart
/// RebuildTracker(
///   name: 'ProductTile',
///   child: ProductTile(product: product),
/// )
/// ```
///
/// In debug mode only:
/// - Counts every [build] call
/// - Optionally shows an overlay badge with rebuild count
/// - Optionally logs to console
/// - Reports to [RebuildStats] for the dashboard
///
/// In release builds, this widget simply returns [child] with no overhead.
class RebuildTracker extends StatefulWidget {
  const RebuildTracker({
    super.key,
    required this.name,
    required this.child,
    this.showOverlay = true,
    this.logToConsole = false,
    this.thresholds = RebuildThresholds.defaultThresholds,
    this.maxRebuildsToWarn,
  });

  /// Unique name for this tracked widget (used in stats and logs).
  final String name;

  /// The widget to track.
  final Widget child;

  /// Whether to show a small overlay badge with rebuild count.
  /// Defaults to true in debug mode.
  final bool showOverlay;

  /// Whether to log each rebuild to the console via [debugPrint].
  final bool logToConsole;

  /// Thresholds for badge color (green/yellow/red).
  final RebuildThresholds thresholds;

  /// If set, logs a warning when rebuild count exceeds this value.
  final int? maxRebuildsToWarn;

  @override
  State<RebuildTracker> createState() => _RebuildTrackerState();
}

class _RebuildTrackerState extends State<RebuildTracker> {
  void _onBuild() {
    if (!kDebugMode) return;

    RebuildStats.instance.recordRebuild(widget.name);
    final count = RebuildStats.instance.getStats(widget.name)?.buildCount ?? 0;

    if (widget.logToConsole) {
      debugPrint('[RebuildTracker] ${widget.name} rebuilt (×$count)');
    }

    if (widget.maxRebuildsToWarn != null && count >= widget.maxRebuildsToWarn!) {
      debugPrint(
        '[RebuildTracker] ⚠️ ${widget.name} exceeded ${widget.maxRebuildsToWarn} rebuilds (current: $count)',
      );
    }
  }

  Color _getBadgeColor(int count) {
    final t = widget.thresholds;
    if (count < t.stableThreshold) return Colors.green;
    if (count < t.warningThreshold) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    _onBuild();

    if (!kDebugMode) {
      return widget.child;
    }

    if (!widget.showOverlay) {
      return widget.child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          top: -4,
          right: -4,
          child: ValueListenableBuilder<int>(
            valueListenable: RebuildStats.instance.updateNotifier,
            builder: (context, _, __) {
              final stats = RebuildStats.instance.getStats(widget.name);
              final count = stats?.buildCount ?? 0;
              return _RebuildBadge(
                count: count,
                color: _getBadgeColor(count),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RebuildBadge extends StatelessWidget {
  const _RebuildBadge({
    required this.count,
    required this.color,
  });

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '×$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
