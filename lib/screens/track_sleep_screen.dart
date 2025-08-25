import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/frosted.dart';
import '../state/sleep_tips_store.dart';
import '../state/sleep_store.dart';
import '../models/sleep_log.dart';
import '../utils/battery_optimizer.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class TrackSleepScreen extends StatefulWidget {
  const TrackSleepScreen({super.key});

  @override
  State<TrackSleepScreen> createState() => _TrackSleepScreenState();
}

class _TrackSleepScreenState extends State<TrackSleepScreen>
    with WidgetsBindingObserver {
  bool _sleeping = false; // true after Start until Stop
  bool _paused = false; // toggled by Pause/Resume
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  DateTime? _sleepStartTime;
  late String _tips = SleepTipsStore.instance.tips;
  bool _hasPermissions = false;
  bool _isOptimized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionsAndOptimization();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Re-check permissions when app becomes active (user returns from settings)
    if (state == AppLifecycleState.resumed) {
      _checkPermissionsAndOptimization();
    }
  }

  Future<void> _checkPermissionsAndOptimization() async {
    try {
      final hasPermissions = await BatteryOptimizer.hasAllRequiredPermissions();
      final isOptimized =
          await BatteryOptimizer.isIgnoringBatteryOptimizations();

      if (mounted) {
        setState(() {
          _hasPermissions = hasPermissions;
          _isOptimized = isOptimized;
        });
      }
    } catch (e) {
      // Handle any errors in permission checking
      if (mounted) {
        setState(() {
          _hasPermissions = false;
          _isOptimized = false;
        });
      }
    }
  }

  String _formatElapsed(Duration? d) {
    final Duration dur = d ?? Duration.zero;
    final int h = dur.inHours;
    final int m = dur.inMinutes.remainder(60);
    final int s = dur.inSeconds.remainder(60);
    final String hh = h.toString().padLeft(2, '0');
    final String mm = m.toString().padLeft(2, '0');
    final String ss = s.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  Future<void> _startSleep() async {
    // Request permissions if not granted
    if (!_hasPermissions) {
      final statuses = await BatteryOptimizer.requestSleepTrackingPermissions();
      final hasAllPermissions = statuses.values.every(
        (status) => status.isGranted,
      );

      if (!hasAllPermissions) {
        if (!mounted) return;
        _showPermissionDialog();
        return;
      }

      // Re-check permissions after user grants them
      await _checkPermissionsAndOptimization();

      // If still no permissions after re-check, show dialog
      if (!_hasPermissions) {
        if (!mounted) return;
        _showPermissionDialog();
        return;
      }
    }

    // Request battery optimization exemption if not already optimized
    if (!_isOptimized) {
      final optimized =
          await BatteryOptimizer.requestBatteryOptimizationExemption();
      setState(() => _isOptimized = optimized);
    }

    // Start the sleep tracking service
    await BatteryOptimizer.startSleepTrackingService();

    setState(() {
      _sleeping = true;
      _paused = false;
      _elapsed = Duration.zero;
      _sleepStartTime = DateTime.now();
    });

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_sleeping && !_paused) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  void _togglePauseResume() {
    setState(() {
      _paused = !_paused;
    });
  }

  Future<void> _stopSleep() async {
    _ticker?.cancel();

    // Stop the sleep tracking service
    await BatteryOptimizer.stopSleepTrackingService();

    // Save sleep log
    if (_sleepStartTime != null) {
      final sleepLog = SleepLog(
        startTime: _sleepStartTime!,
        endTime: DateTime.now(),
        duration: _elapsed,
      );
      SleepStore.instance.add(sleepLog);
    }

    setState(() {
      _sleeping = false;
      _paused = false;
      _elapsed = Duration.zero;
      _sleepStartTime = null;
    });
    if (mounted) Navigator.of(context).maybePop();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Sleep tracking requires activity recognition and sensor permissions to work properly. '
          'Please grant these permissions in settings and then return to this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await BatteryOptimizer.openAppSettings();
              // Re-check permissions when user returns
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  _checkPermissionsAndOptimization();
                }
              });
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _editTips() async {
    final TextEditingController ctrl = TextEditingController(text: _tips);
    final String? updated = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Sleep Tips'),
          content: TextField(
            controller: ctrl,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Enter your tips... (use new lines for bullets)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (updated != null && updated.isNotEmpty) {
      await SleepTipsStore.instance.save(updated);
      if (!mounted) return;
      setState(() => _tips = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Sleep'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const FrostedBarBackground(),
        actions: [
          IconButton(
            tooltip: 'Edit tips',
            onPressed: _editTips,
            icon: const Icon(Icons.edit_note),
          ),
        ],
      ),
      body: Column(
        children: [
          // Permission status indicator
          if (!_hasPermissions || !_isOptimized)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.errorContainer.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: scheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      !_hasPermissions
                          ? 'Permissions required for sleep tracking'
                          : 'Battery optimization may affect sleep tracking',
                      style: TextStyle(color: scheme.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Top metrics (timer + sleep info)
          SizedBox(
            height: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                color: scheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _sleeping ? 'Sleeping' : 'Ready to Sleep',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (!_sleeping)
                            FilledButton.tonal(
                              onPressed: () {},
                              child: const Text('Tonight'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Big timer text
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.nightlight_round,
                                size: 64,
                                color: scheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _formatElapsed(_elapsed),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _sleeping
                                    ? 'Sleep duration'
                                    : 'Tap Start to begin',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sleep tips card
                  if (!_sleeping) ...[
                    Card(
                      elevation: 0,
                      color: scheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sleep Tips',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _tips,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Large Start / Pause / Stop controls
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: !_sleeping
                        ? FilledButton(
                            key: const ValueKey('start'),
                            style: FilledButton.styleFrom(
                              shape: const StadiumBorder(),
                              minimumSize: const Size.fromHeight(72),
                              padding: const EdgeInsets.symmetric(vertical: 26),
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: _startSleep,
                            child: const Text('Start Sleep'),
                          )
                        : Row(
                            key: const ValueKey('controls'),
                            children: [
                              Expanded(
                                child: FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    minimumSize: const Size.fromHeight(64),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 22,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onPressed: _togglePauseResume,
                                  child: Text(_paused ? 'Resume' : 'Pause'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    minimumSize: const Size.fromHeight(64),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 22,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onPressed: _stopSleep,
                                  child: const Text('Wake Up'),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }
}
