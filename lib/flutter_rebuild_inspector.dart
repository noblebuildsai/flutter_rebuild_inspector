/// Flutter Rebuild Inspector
///
/// A runtime widget rebuild visualizer that works inside your app,
/// without DevTools, with minimal setup.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:flutter_rebuild_inspector/flutter_rebuild_inspector.dart';
///
/// // Wrap any widget you want to track
/// RebuildTracker(
///   name: 'ProductTile',
///   child: ProductTile(product: product),
/// )
/// ```
///
/// ## Features
///
/// - **RebuildTracker**: Counts how many times a widget rebuilds
/// - **Visual badge**: Red/yellow/green overlay based on rebuild frequency
/// - **RebuildInspectorDashboard**: In-app list of top rebuilt widgets
/// - **RebuildStats**: Programmatic access to rebuild statistics
///
/// All features are debug-only and have no impact on release builds.
library;

export 'src/rebuild_inspector_dashboard.dart';
export 'src/rebuild_heatmap_overlay.dart';
export 'src/rebuild_inspector_overlay.dart';
export 'src/rebuild_stats.dart';
export 'src/rebuild_tracker.dart';
export 'src/performance_suggestions.dart';
