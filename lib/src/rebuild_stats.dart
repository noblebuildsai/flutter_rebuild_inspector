import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A heatmap entry with widget bounds and rebuild count.
class HeatmapEntry {
  const HeatmapEntry({
    required this.name,
    required this.rect,
    required this.buildCount,
  });

  final String name;
  final ui.Rect rect;
  final int buildCount;
}

/// Possible inferred reasons for a widget rebuild.
enum RebuildReason {
  /// Likely triggered by setState.
  setState,

  /// Likely triggered by InheritedWidget/Provider/Consumer.
  inheritedWidget,

  /// Likely triggered by StreamBuilder/FutureBuilder.
  asyncBuilder,

  /// Likely triggered by BlocBuilder/BlocConsumer.
  blocBuilder,

  /// Unknown or could not infer.
  unknown,
}

/// Holds rebuild statistics for a single tracked widget.
@immutable
class WidgetRebuildStats {
  const WidgetRebuildStats({
    required this.name,
    required this.buildCount,
    required this.lastRebuildAt,
    this.inferredReason,
  });

  /// The name given to the tracked widget.
  final String name;

  /// Total number of times the widget has rebuilt.
  final int buildCount;

  /// Timestamp of the last rebuild (milliseconds since app start).
  final int lastRebuildAt;

  /// Inferred reason for rebuilds (when [RebuildTracker.captureReason] is true).
  final RebuildReason? inferredReason;

  @override
  String toString() => 'WidgetRebuildStats($name: $buildCount rebuilds)';
}

/// Global singleton that collects rebuild statistics from all [RebuildTracker] widgets.
///
/// Only active in debug mode. In release builds, all methods are no-ops.
class RebuildStats {
  RebuildStats._();
  static final RebuildStats _instance = RebuildStats._();

  /// The global [RebuildStats] instance.
  static RebuildStats get instance => _instance;

  /// When true (default in debug mode), logs key events to console.
  /// Set to false to disable debug logs.
  static bool enableDebugLogs = kDebugMode;

  final Map<String, _WidgetStats> _stats = {};
  final Map<String, GlobalKey> _heatmapKeys = {};
  final ValueNotifier<int> _updateNotifier = ValueNotifier(0);

  /// Listen to this to rebuild when stats change (e.g. for dashboard).
  ValueListenable<int> get updateNotifier => _updateNotifier;

  /// Records a rebuild for the widget with [name].
  /// Pass [stackTrace] to infer rebuild reason (optional, has overhead).
  void recordRebuild(String name, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;

    _stats[name] ??= _WidgetStats(name: name);
    final stats = _stats[name]!;
    final prevCount = stats.buildCount;
    stats.increment(stackTrace);

    if (enableDebugLogs && stats.buildCount >= 20 && prevCount < 20) {
      debugPrint('[RebuildInspector] ⚠️ "$name" exceeded 20 rebuilds (×${stats.buildCount})');
    } else if (enableDebugLogs && stats.buildCount >= 50 && prevCount < 50) {
      debugPrint('[RebuildInspector] 🔴 "$name" hit 50 rebuilds — consider optimizing');
    }

    _updateNotifier.value++;
  }

  void _log(String message) {
    if (kDebugMode && enableDebugLogs) {
      debugPrint('[RebuildInspector] $message');
    }
  }

  /// Returns the current stats for [name], or null if not tracked.
  WidgetRebuildStats? getStats(String name) {
    if (!kDebugMode) return null;
    final s = _stats[name];
    return s != null
        ? WidgetRebuildStats(
            name: s.name,
            buildCount: s.buildCount,
            lastRebuildAt: s.lastRebuildAt,
            inferredReason: s.inferredReason,
          )
        : null;
  }

  /// Returns stats for all tracked widgets, sorted by build count (highest first).
  List<WidgetRebuildStats> getAllStats() {
    if (!kDebugMode) return [];
    return _stats.values
        .map((s) => WidgetRebuildStats(
              name: s.name,
              buildCount: s.buildCount,
              lastRebuildAt: s.lastRebuildAt,
              inferredReason: s.inferredReason,
            ))
        .toList()
      ..sort((a, b) => b.buildCount.compareTo(a.buildCount));
  }

  /// Returns the top [n] most rebuilt widgets.
  List<WidgetRebuildStats> getTopRebuilt(int n) {
    return getAllStats().take(n).toList();
  }

  /// Registers a [GlobalKey] for heatmap overlay. The key must be attached
  /// to a widget that has a [RenderBox].
  void registerHeatmapKey(String name, GlobalKey key) {
    if (!kDebugMode) return;
    _heatmapKeys[name] = key;
  }

  /// Unregisters a heatmap key (call when widget is disposed).
  void unregisterHeatmapKey(String name) {
    if (!kDebugMode) return;
    _heatmapKeys.remove(name);
  }

  /// Returns heatmap entries for all registered widgets that are on screen.
  List<HeatmapEntry> getHeatmapEntries() {
    if (!kDebugMode) return [];
    final entries = <HeatmapEntry>[];
    for (final entry in _heatmapKeys.entries) {
      final name = entry.key;
      final key = entry.value;
      final renderObject = key.currentContext?.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize && renderObject.attached) {
        final box = renderObject;
        final rect = box.localToGlobal(ui.Offset.zero) & box.size;
        final stats = getStats(name);
        if (stats != null) {
          entries.add(HeatmapEntry(
            name: name,
            rect: rect,
            buildCount: stats.buildCount,
          ));
        }
      }
    }
    return entries;
  }

  /// Resets the build count for [name].
  void reset(String name) {
    if (!kDebugMode) return;
    _stats[name]?.reset();
    _updateNotifier.value++;
  }

  /// Resets all build counts.
  void resetAll() {
    if (!kDebugMode) return;
    for (final s in _stats.values) {
      s.reset();
    }
    _log('Reset all rebuild counts');
    _updateNotifier.value++;
  }

  /// Clears all tracked widgets from the stats.
  void clear() {
    if (!kDebugMode) return;
    _stats.clear();
    _heatmapKeys.clear();
  }

  /// Whether the inspector is enabled (debug mode).
  bool get isEnabled => kDebugMode;
}

class _WidgetStats {
  _WidgetStats({required this.name});

  final String name;
  int buildCount = 0;
  int lastRebuildAt = 0;
  RebuildReason? inferredReason;

  void increment([StackTrace? stackTrace]) {
    buildCount++;
    lastRebuildAt = DateTime.now().millisecondsSinceEpoch;
    if (stackTrace != null) {
      inferredReason = _inferReasonFromStack(stackTrace);
    }
  }

  void reset() {
    buildCount = 0;
    inferredReason = null;
  }
}

RebuildReason? _inferReasonFromStack(StackTrace stackTrace) {
  final str = stackTrace.toString();
  if (str.contains('setState')) {
    return RebuildReason.setState;
  }
  if (str.contains('Consumer') || str.contains('Provider') ||
      str.contains('InheritedWidget') || str.contains('context.watch')) {
    return RebuildReason.inheritedWidget;
  }
  if (str.contains('StreamBuilder') || str.contains('FutureBuilder')) {
    return RebuildReason.asyncBuilder;
  }
  if (str.contains('BlocBuilder') || str.contains('BlocConsumer')) {
    return RebuildReason.blocBuilder;
  }
  return RebuildReason.unknown;
}
