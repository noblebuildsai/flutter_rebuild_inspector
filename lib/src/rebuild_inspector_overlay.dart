import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'rebuild_heatmap_overlay.dart';
import 'rebuild_inspector_dashboard.dart';

/// A convenience overlay that adds a floating button to toggle the rebuild dashboard.
///
/// Wrap your app's root widget to enable one-tap access to the dashboard:
///
/// ```dart
/// MaterialApp(
///   home: RebuildInspectorOverlay(
///     child: MyHomePage(),
///   ),
/// )
/// ```
///
/// Only active in debug mode. In release, simply returns [child].
class RebuildInspectorOverlay extends StatefulWidget {
  const RebuildInspectorOverlay({
    super.key,
    required this.child,
    this.dashboardTopN = 10,
    this.position = Alignment.topRight,
  });

  /// The app content.
  final Widget child;

  /// Number of top widgets to show in the dashboard.
  final int dashboardTopN;

  /// Position of the toggle button.
  final Alignment position;

  @override
  State<RebuildInspectorOverlay> createState() => _RebuildInspectorOverlayState();
}

class _RebuildInspectorOverlayState extends State<RebuildInspectorOverlay> {
  bool _showDashboard = false;
  bool _showHeatmap = false;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_showHeatmap) const RebuildHeatmapOverlay(),
        Positioned(
          top: widget.position.y <= 0 ? 50 : null,
          bottom: widget.position.y > 0 ? 50 : null,
          left: widget.position.x <= 0 ? 16 : null,
          right: widget.position.x > 0 ? 16 : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: widget.position.x == 1
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (_showDashboard) ...[
                RebuildInspectorDashboard(
                  topN: widget.dashboardTopN,
                  maxHeight: 250,
                  onReset: () => setState(() {}),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showDashboard)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(16),
                              child: RebuildInspectorDashboard(
                                topN: widget.dashboardTopN,
                                fullScreen: true,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _showHeatmap = !_showHeatmap),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _showHeatmap ? Colors.orange.shade700 : Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.grid_on, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _showDashboard = !_showDashboard),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _showDashboard
                              ? Colors.blue.shade700
                              : Colors.black87,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _showDashboard ? Icons.close : Icons.speed,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
