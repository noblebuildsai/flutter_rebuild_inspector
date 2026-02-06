import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'rebuild_stats.dart';

/// An in-app dashboard that shows the top rebuilt widgets.
///
/// Add this to your app (e.g., as an overlay or debug screen) to see
/// which widgets are rebuilding the most.
///
/// Only renders in debug mode. In release, returns [SizedBox.shrink].
///
/// ```dart
/// // As a floating overlay
/// Stack(
///   children: [
///     YourApp(),
///     Positioned(
///       top: 50,
///       right: 16,
///       child: RebuildInspectorDashboard(topN: 10),
///     ),
///   ],
/// )
/// ```
class RebuildInspectorDashboard extends StatelessWidget {
  const RebuildInspectorDashboard({
    super.key,
    this.topN = 10,
    this.maxHeight = 300,
    this.onReset,
  });

  /// Number of top rebuilt widgets to display.
  final int topN;

  /// Maximum height of the dashboard.
  final double maxHeight;

  /// Callback when reset is pressed.
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return _RebuildDashboardContent(
      topN: topN,
      maxHeight: maxHeight,
      onReset: onReset,
    );
  }
}

class _RebuildDashboardContent extends StatelessWidget {
  const _RebuildDashboardContent({
    required this.topN,
    required this.maxHeight,
    this.onReset,
  });

  final int topN;
  final double maxHeight;
  final VoidCallback? onReset;

  Color _colorForCount(int count) {
    if (count < 5) return Colors.green;
    if (count < 20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: RebuildStats.instance.updateNotifier,
      builder: (context, _, __) => _DashboardBody(
        topN: topN,
        maxHeight: maxHeight,
        onReset: onReset,
        colorForCount: _colorForCount,
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.topN,
    required this.maxHeight,
    this.onReset,
    required this.colorForCount,
  });

  final int topN;
  final double maxHeight;
  final VoidCallback? onReset;
  final Color Function(int) colorForCount;

  @override
  Widget build(BuildContext context) {
    final stats = RebuildStats.instance.getTopRebuilt(topN);

    if (stats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: const Text(
          'No tracked widgets yet.\nWrap widgets with RebuildTracker.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🔄 Rebuild Inspector',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    RebuildStats.instance.resetAll();
                    onReset?.call();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Reset', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final s = stats[index];
                final color = colorForCount(s.buildCount);
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    s.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '×${s.buildCount}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
