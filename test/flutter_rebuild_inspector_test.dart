import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rebuild_inspector/flutter_rebuild_inspector.dart';

void main() {
  group('RebuildTracker', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RebuildTracker(
            name: 'TestWidget',
            child: const Text('Hello'),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('increments rebuild count on each build', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return RebuildTracker(
                name: 'Counter',
                showOverlay: false,
                child: GestureDetector(
                  onTap: () => setState(() => buildCount++),
                  child: Text('Count: $buildCount'),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      await tester.tap(find.text('Count: 0'));
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);

      await tester.tap(find.text('Count: 1'));
      await tester.pump();

      expect(find.text('Count: 2'), findsOneWidget);
    });
  });

  group('RebuildStats', () {
    test('getStats returns null for untracked widget', () {
      RebuildStats.instance.clear();
      expect(RebuildStats.instance.getStats('NonExistent'), isNull);
    });

    test('getAllStats returns empty when no widgets tracked', () {
      RebuildStats.instance.clear();
      expect(RebuildStats.instance.getAllStats(), isEmpty);
    });
  });

  group('RebuildThresholds', () {
    test('default thresholds have expected values', () {
      const t = RebuildThresholds.defaultThresholds;
      expect(t.stableThreshold, 5);
      expect(t.warningThreshold, 20);
    });
  });
}
