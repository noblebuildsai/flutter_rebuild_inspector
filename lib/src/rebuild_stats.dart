import 'package:flutter/foundation.dart';

/// Holds rebuild statistics for a single tracked widget.
@immutable
class WidgetRebuildStats {
  const WidgetRebuildStats({
    required this.name,
    required this.buildCount,
    required this.lastRebuildAt,
  });

  /// The name given to the tracked widget.
  final String name;

  /// Total number of times the widget has rebuilt.
  final int buildCount;

  /// Timestamp of the last rebuild (milliseconds since app start).
  final int lastRebuildAt;

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

  final Map<String, _WidgetStats> _stats = {};
  final ValueNotifier<int> _updateNotifier = ValueNotifier(0);

  /// Listen to this to rebuild when stats change (e.g. for dashboard).
  ValueListenable<int> get updateNotifier => _updateNotifier;

  /// Records a rebuild for the widget with [name].
  void recordRebuild(String name) {
    if (!kDebugMode) return;

    _stats[name] ??= _WidgetStats(name: name);
    _stats[name]!.increment();
    _updateNotifier.value++;
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
            ))
        .toList()
      ..sort((a, b) => b.buildCount.compareTo(a.buildCount));
  }

  /// Returns the top [n] most rebuilt widgets.
  List<WidgetRebuildStats> getTopRebuilt(int n) {
    return getAllStats().take(n).toList();
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
    _updateNotifier.value++;
  }

  /// Clears all tracked widgets from the stats.
  void clear() {
    if (!kDebugMode) return;
    _stats.clear();
  }

  /// Whether the inspector is enabled (debug mode).
  bool get isEnabled => kDebugMode;
}

class _WidgetStats {
  _WidgetStats({required this.name});

  final String name;
  int buildCount = 0;
  int lastRebuildAt = 0;

  void increment() {
    buildCount++;
    lastRebuildAt = DateTime.now().millisecondsSinceEpoch;
  }

  void reset() {
    buildCount = 0;
  }
}
