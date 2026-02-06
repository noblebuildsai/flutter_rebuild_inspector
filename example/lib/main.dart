import 'package:flutter/material.dart';
import 'package:flutter_rebuild_inspector/flutter_rebuild_inspector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rebuild Inspector Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RebuildInspectorOverlay(
        child: DemoHomePage(),
      ),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  int _counter = 0;
  bool _toggle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rebuild Inspector Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tap the speed icon (top-right) to see the dashboard'),
            const SizedBox(height: 24),
            RebuildTracker(
              name: 'CounterDisplay',
              child: Text(
                'Counter: $_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            RebuildTracker(
              name: 'ToggleDisplay',
              child: Text(
                'Toggle: $_toggle',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 32),
            RebuildTracker(
              name: 'ButtonRow',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _counter++),
                    child: const Text('Increment'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _toggle = !_toggle),
                    child: const Text('Toggle'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            RebuildTracker(
              name: 'StaticWidget',
              showOverlay: true,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'This widget only rebuilds when parent rebuilds',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
