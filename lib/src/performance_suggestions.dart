import 'package:flutter/foundation.dart';

import 'rebuild_stats.dart';

/// A performance suggestion for a widget with high rebuild count.
@immutable
class PerformanceSuggestion {
  const PerformanceSuggestion({
    required this.widgetName,
    required this.message,
    this.fix,
    this.rebuildCount,
  });

  /// The name of the widget this suggestion applies to.
  final String widgetName;

  /// Human-readable suggestion message.
  final String message;

  /// Optional specific fix to apply.
  final String? fix;

  /// The rebuild count that triggered this suggestion.
  final int? rebuildCount;

  @override
  String toString() => 'PerformanceSuggestion($widgetName: $message)';
}

/// Infers rebuild reasons and generates performance suggestions.
///
/// Uses heuristics based on rebuild count and optional stack trace analysis.
class PerformanceSuggestions {
  PerformanceSuggestions._();

  static const int _highRebuildThreshold = 20;
  static const int _mediumRebuildThreshold = 10;

  /// Returns performance suggestions for widgets with high rebuild counts.
  static List<PerformanceSuggestion> getSuggestions() {
    if (!kDebugMode) return [];

    final stats = RebuildStats.instance.getAllStats();
    final suggestions = <PerformanceSuggestion>[];

    for (final s in stats) {
      if (s.buildCount >= _highRebuildThreshold) {
        suggestions.addAll(_suggestionsForWidget(s.name, s.buildCount, high: true));
      } else if (s.buildCount >= _mediumRebuildThreshold) {
        suggestions.addAll(_suggestionsForWidget(s.name, s.buildCount, high: false));
      }
    }

    return suggestions;
  }

  static List<PerformanceSuggestion> _suggestionsForWidget(
    String name,
    int count, {
    required bool high,
  }) {
    return [
      PerformanceSuggestion(
        widgetName: name,
        message: high
            ? 'Widget "$name" rebuilt $count times — likely causing jank'
            : 'Widget "$name" rebuilt $count times — worth optimizing',
        fix: high
            ? 'Try: const, Selector instead of Consumer, or move setState lower'
            : 'Consider: const constructor, or extracting to separate widget',
        rebuildCount: count,
      ),
    ];
  }
}
