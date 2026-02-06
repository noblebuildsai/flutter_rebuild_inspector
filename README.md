# Flutter Rebuild Inspector

A runtime widget rebuild visualizer for Flutter. Track rebuild counts, see visual badges (red/yellow/green), and view an in-app dashboard—**no DevTools needed**.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)

## The Problem

Flutter widgets rebuild a lot. Too many rebuilds = performance issues. But Flutter doesn't tell you:

> "Hey, this widget rebuilt 87 times in 3 seconds."

You end up guessing, adding `print()` statements, or wrapping everything in `const` and praying 🙃

## The Solution

**Flutter Rebuild Inspector** gives you instant visual feedback inside your app:

- 🔴 **Red badge** → Rebuilding too often
- 🟡 **Yellow badge** → Medium rebuilds  
- 🟢 **Green badge** → Stable

Works with **any state management** (Provider, Riverpod, Bloc, GetX, setState, etc.)—we just count `build()` calls.

## Features

- **RebuildTracker** — Wrap any widget to count its rebuilds
- **Visual overlay** — Color-coded badges (green/yellow/red) based on thresholds
- **RebuildInspectorDashboard** — In-app list of top rebuilt widgets
- **RebuildInspectorOverlay** — Floating buttons: dashboard, heatmap, full-screen
- **RebuildHeatmapOverlay** — Visual heatmap with colored borders around widgets
- **Performance suggestions** — Dashboard shows optimization tips for high-rebuild widgets
- **Rebuild reason inference** — Optional stack trace analysis (setState, Provider, etc.)
- **RebuildStats** — Programmatic access to statistics
- **Debug-only** — Zero overhead in release builds

## Installation

```yaml
dependencies:
  flutter_rebuild_inspector: ^0.1.0
```

## Quick Start

### 1. Wrap widgets you want to track

```dart
import 'package:flutter_rebuild_inspector/flutter_rebuild_inspector.dart';

RebuildTracker(
  name: 'ProductTile',
  child: ProductTile(product: product),
)
```

### 2. Add the overlay (optional)

Wrap your app to get a floating button that toggles the dashboard:

```dart
MaterialApp(
  home: RebuildInspectorOverlay(
    child: MyHomePage(),
  ),
)
```

### 3. Tap the speed icon → dashboard | grid icon → heatmap | expand → full-screen

## Usage

### RebuildTracker

```dart
RebuildTracker(
  name: 'MyWidget',           // Unique name for stats
  child: MyWidget(),
  showOverlay: true,           // Show badge (default: true)
  logToConsole: false,        // Log each rebuild to console
  maxRebuildsToWarn: 20,       // Log warning when exceeded
  thresholds: RebuildThresholds(
    stableThreshold: 5,       // Green below this
    warningThreshold: 20,     // Red above this
  ),
)
```

### RebuildInspectorDashboard

Add the dashboard anywhere (e.g., a debug screen):

```dart
RebuildInspectorDashboard(
  topN: 10,        // Show top 10 rebuilt widgets
  maxHeight: 300,
  onReset: () {},   // Called when reset is pressed
)
```

### RebuildHeatmapOverlay

Add heatmap to visualize rebuild hotspots. Use `enableHeatmap: true` on RebuildTracker:

```dart
RebuildTracker(
  name: 'ProductTile',
  enableHeatmap: true,
  child: ProductTile(product: product),
)
```

Then add the overlay (or use RebuildInspectorOverlay which includes it):

```dart
Stack(
  children: [
    YourApp(),
    RebuildHeatmapOverlay(),
  ],
)
```

### RebuildStats (programmatic)

```dart
// Get stats for a specific widget
final stats = RebuildStats.instance.getStats('ProductTile');

// Get top rebuilt widgets
final top = RebuildStats.instance.getTopRebuilt(5);

// Reset counts
RebuildStats.instance.reset('ProductTile');
RebuildStats.instance.resetAll();

// Disable debug logs (enabled by default in debug mode)
RebuildStats.enableDebugLogs = false;
```

### Debug logging (debug mode)

When running in debug mode, the inspector automatically logs:

- **On init**: "🔄 Active (debug mode) — tap speed icon for dashboard, grid for heatmap"
- **At 20 rebuilds**: "⚠️ [widget] exceeded 20 rebuilds"
- **At 50 rebuilds**: "🔴 [widget] hit 50 rebuilds — consider optimizing"
- **On reset**: "Reset all rebuild counts"

Disable with `RebuildStats.enableDebugLogs = false`.

## Example

Run the example app:

```bash
cd example && flutter run
```

Tap the buttons to trigger rebuilds. Tap the speed icon (top-right) to see the dashboard.

## Thresholds

| Rebuilds | Color  | Meaning                    |
|----------|--------|----------------------------|
| < 5      | Green  | Stable                     |
| 5–20     | Yellow | Medium (worth watching)    |
| > 20     | Red    | Rebuilding too often       |

Customize with `RebuildThresholds`.

## Compatibility

Works with **all state management** solutions:

- setState
- Provider
- Riverpod
- Bloc / Cubit
- GetX
- InheritedWidget
- StreamBuilder
- FutureBuilder
- ValueListenableBuilder
- ...and more

We only observe `build()` calls—we don't care what triggered them.

## Performance

- **Debug mode**: Small overhead from counting and overlay
- **Release mode**: **Zero overhead** — all tracking is disabled

Always use in debug/development. Remove or the package no-ops automatically in release.

## License

MIT
