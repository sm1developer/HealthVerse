import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'track_workout_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../state/workout_store.dart';
import '../models/workout.dart';
import 'package:hive/hive.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool? _expanded = false;

  Future<void> _onActionSelected(String action) async {
    if (!mounted) return;
    if (action == 'Track Workout') {
      // On Android, request ACTIVITY_RECOGNITION at runtime.
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.activityRecognition.request();
        if (!(status.isGranted || status.isLimited)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission required to track workouts.'),
            ),
          );
          return;
        }
      }
      if (!mounted) return;
      setState(() => _expanded = false);
      // Navigate and wait
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const TrackWorkoutScreen()));
      if (!mounted) return;
      setState(() {});
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(action)));
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    const double spacing = 12;
    final bool isExpanded = _expanded == true;
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tileBg =
        (isDark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surfaceContainerHighest)
            .withValues(alpha: isDark ? 0.25 : 0.6);
    final Color outline = colorScheme.outlineVariant;

    // Taller pill style for menu options
    final ButtonStyle pillStyle = FilledButton.styleFrom(
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      minimumSize: const Size(0, 56),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: Stack(
        children: [
          // Saved workouts list backed by Hive listenable
          ValueListenableBuilder<Box<Workout>>(
            valueListenable: WorkoutStore.instance.listenable!,
            builder: (context, box, _) {
              final List<Workout> list = box.values
                  .toList()
                  .cast<Workout>()
                  .reversed
                  .toList();
              return ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 120,
                  left: 16,
                  right: 16,
                  top: 8,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final Workout w = list[index];
                  final String hh = w.elapsed.inHours.toString().padLeft(
                    2,
                    '0',
                  );
                  final String mm = w.elapsed.inMinutes
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final String ss = w.elapsed.inSeconds
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final DateTime dt = w.startedAt;
                  final int rawH = dt.hour % 12;
                  final int hr12 = rawH == 0 ? 12 : rawH;
                  final String min = dt.minute.toString().padLeft(2, '0');
                  final String meridiem = dt.hour < 12 ? 'AM' : 'PM';
                  final String time12 =
                      '${hr12.toString().padLeft(2, '0')}:$min $meridiem';
                  return Card(
                    color: tileBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: outline.withValues(alpha: 0.6)),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(w.activity),
                      subtitle: Text('Time: $hh:$mm:$ss  •  Steps: ${w.steps}'),
                      trailing: Text(time12),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 16 + viewPadding.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SizeTransition(
                      sizeFactor: anim,
                      axisAlignment: -1,
                      child: child,
                    ),
                  ),
                  child: !isExpanded
                      ? const SizedBox.shrink()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.tonalIcon(
                                style: pillStyle,
                                onPressed: () =>
                                    _onActionSelected('Track Workout'),
                                icon: const Icon(Icons.fitness_center),
                                label: const Text('Track Workout'),
                              ),
                            ),
                            const SizedBox(height: spacing),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.tonalIcon(
                                style: pillStyle,
                                onPressed: () => _onActionSelected('Log Food'),
                                icon: const Icon(Icons.restaurant),
                                label: const Text('Log Food'),
                              ),
                            ),
                            const SizedBox(height: spacing),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.tonalIcon(
                                style: pillStyle,
                                onPressed: () => _onActionSelected('Log Water'),
                                icon: const Icon(Icons.water_drop),
                                label: const Text('Log Water'),
                              ),
                            ),
                            const SizedBox(height: spacing),
                          ],
                        ),
                ),
                FloatingActionButton(
                  shape: const CircleBorder(),
                  onPressed: () => setState(() => _expanded = !(isExpanded)),
                  tooltip: isExpanded ? 'Close' : 'Add',
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.125 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
