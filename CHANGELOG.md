## 0.2.2

* **Fix** — Resolve "setState/markNeedsBuild called during build" when using RebuildTracker with ValueListenableBuilder (e.g. GetX Obx). Rebuild notifications are now deferred via `addPostFrameCallback` so they occur after the build phase.

## 0.2.1

* **Debug logging** — Automatic logs in debug mode: init message, 20/50 rebuild warnings, reset confirmation
* **RebuildStats.enableDebugLogs** — Toggle to disable logs (default: true in debug)

## 0.2.0

* **Full-screen dashboard** — Expand button opens dashboard in full-screen dialog
* **Heatmap overlay** — Visual borders around tracked widgets (green/yellow/red)
* **RebuildHeatmapOverlay** — Toggle heatmap via grid icon in overlay
* **enableHeatmap** — RebuildTracker parameter to include widget in heatmap
* **captureReason** — Optional stack trace capture to infer rebuild reason
* **RebuildReason** — Enum: setState, inheritedWidget, asyncBuilder, blocBuilder
* **Performance suggestions** — Dashboard shows optimization tips for high-rebuild widgets
* **PerformanceSuggestions** — Programmatic access to suggestions

## 0.1.1

* Fix LICENSE file (replace TODO with proper MIT license).

## 0.1.0

* Initial release.
* **RebuildTracker** — Wrap widgets to count rebuilds with optional visual badge
* **RebuildInspectorDashboard** — In-app list of top rebuilt widgets
* **RebuildInspectorOverlay** — Floating button to toggle dashboard
* **RebuildStats** — Programmatic access to rebuild statistics
* Color-coded badges: green (< 5), yellow (5–20), red (> 20)
* Debug-only: zero overhead in release builds
