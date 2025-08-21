import 'package:flutter/material.dart';
import 'dart:async';
import '../state/workout_store.dart';
import '../models/workout.dart';
import 'package:pedometer/pedometer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import '../widgets/frosted.dart';

class TrackWorkoutScreen extends StatefulWidget {
  const TrackWorkoutScreen({super.key});

  @override
  State<TrackWorkoutScreen> createState() => _TrackWorkoutScreenState();
}

class _TrackWorkoutScreenState extends State<TrackWorkoutScreen> {
  String _activity = 'Walking';
  bool _running = false; // true after Start until Stop
  bool _paused = false; // toggled by Pause/Resume
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  int _steps = 0;
  StreamSubscription<StepCount>? _stepSub;
  int? _baselineSteps; // initial hardware steps to offset

  final List<String> _activities = const [
    'Walking',
    'Running',
    'Cycling',
    'Motorbike',
    'Hiking',
  ];

  final Map<String, IconData> _activityIcons = const {
    'Walking': Icons.directions_walk,
    'Running': Icons.directions_run,
    'Cycling': Icons.directions_bike,
    'Motorbike': Icons.two_wheeler,
    'Hiking': Icons.terrain,
  };

  Future<void> _chooseActivity() async {
    final String? picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ActivityPickerPage(
          activities: _activities,
          current: _activity,
          activityIcons: _activityIcons,
        ),
      ),
    );
    if (picked != null) {
      setState(() => _activity = picked);
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

  void _start() {
    setState(() {
      _running = true;
      _paused = false;
      _elapsed = Duration.zero;
      _steps = 0;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_running && !_paused) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
          // If no pedometer stream, use simple synthetic model
          if (_stepSub == null) {
            final String a = _activity;
            int perSec = 1; // default gentle pace
            if (a == 'Walking') perSec = 2;
            if (a == 'Running') perSec = 3;
            if (a == 'Hiking') perSec = 2;
            if (a == 'Cycling' || a == 'Motorbike') perSec = 0; // no steps
            _steps += perSec;
          }
        });
      }
    });
    _startPedometerIfAvailable();
  }

  void _togglePauseResume() {
    setState(() {
      _paused = !_paused;
    });
  }

  void _stop() {
    _ticker?.cancel();
    _stepSub?.cancel();
    _stepSub = null;
    _baselineSteps = null;
    // Save workout before clearing state
    final workout = Workout(
      activity: _activity,
      elapsed: _elapsed,
      steps: _steps,
      startedAt: DateTime.now().subtract(_elapsed),
    );
    WorkoutStore.instance.add(workout);
    setState(() {
      _running = false;
      _paused = false;
      _elapsed = Duration.zero;
      _steps = 0;
    });
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Workout'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const FrostedBarBackground(),
      ),
      body: Column(
        children: [
          // Top metrics (timer placeholder + steps)
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
                            _running ? 'Elapsed' : 'Ready',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (!_running)
                            FilledButton.tonal(
                              onPressed: _chooseActivity,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _activityIcons[_activity] ??
                                        Icons.flag_circle,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_activity),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Big timer text
                      Expanded(
                        child: Center(
                          child: Text(
                            _formatElapsed(_elapsed),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Steps
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_walk),
                          const SizedBox(width: 8),
                          Text(
                            'Steps: $_steps',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom selectors and controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Activity selector (visible only before starting)
                  if (!_running) ...[
                    Text(
                      'Activity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: Theme.of(context).colorScheme.surface,
                      leading: Icon(_activityIcons[_activity] ?? Icons.flag),
                      title: Text(_activity),
                      trailing: FilledButton.tonalIcon(
                        onPressed: _chooseActivity,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Change'),
                      ),
                      onTap: _chooseActivity,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Large Start / Pause / Stop controls
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: !_running
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
                            onPressed: _start,
                            child: const Text('Start'),
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
                                  onPressed: _stop,
                                  child: const Text('Stop'),
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
    _ticker?.cancel();
    _stepSub?.cancel();
    super.dispose();
  }

  Future<void> _startPedometerIfAvailable() async {
    if (kIsWeb) return; // not supported
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    // Request permissions where needed (Android Q+)
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      if (!status.isGranted && !status.isLimited) return;
    }

    try {
      _stepSub?.cancel();
      _baselineSteps = null;
      _stepSub = Pedometer.stepCountStream.listen(
        (StepCount event) {
          if (!mounted) return;
          // Some platforms emit cumulative steps since boot. Use baseline offset.
          if (_baselineSteps == null) {
            _baselineSteps = event.steps;
          }
          if (_running && !_paused) {
            final int current = event.steps - (_baselineSteps ?? event.steps);
            setState(() {
              _steps = current < 0 ? 0 : current;
            });
          }
        },
        onError: (e) {
          // If stream fails, keep synthetic fallback.
        },
      );
    } catch (_) {
      // Ignore and continue with synthetic fallback.
    }
  }
}

class _ActivityPickerPage extends StatelessWidget {
  const _ActivityPickerPage({
    required this.activities,
    required this.current,
    required this.activityIcons,
  });

  final List<String> activities;
  final String current;
  final Map<String, IconData> activityIcons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose activity'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const FrostedBarBackground(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, current),
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final name = activities[index];
          return RadioListTile<String>(
            value: name,
            groupValue: current,
            onChanged: (v) => Navigator.pop(context, v),
            title: Text(name),
            secondary: Icon(activityIcons[name] ?? Icons.flag),
          );
        },
      ),
    );
  }
}
