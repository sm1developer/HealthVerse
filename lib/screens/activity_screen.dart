import 'package:flutter/material.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'track_workout_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../state/workout_store.dart';
import '../models/workout.dart';
import 'package:hive/hive.dart';
import '../widgets/frosted.dart';
import 'log_water_screen.dart';
import 'log_food_screen.dart';
import '../state/water_store.dart';
import '../models/water_log.dart';
import '../state/food_store.dart';
import '../models/food_log.dart';
import 'track_sleep_screen.dart';
import '../state/sleep_store.dart';
import '../models/sleep_log.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, this.dimmer, this.floatingLayer});

  final ValueNotifier<bool>? dimmer;
  final ValueNotifier<Widget?>? floatingLayer;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool? _expanded = false;
  VoidCallback? _dimmerSub;
  bool _selectionMode = false;
  final Set<String> _selectedIds = <String>{};
  final Map<String, _ActivityItem> _idToItem = <String, _ActivityItem>{};

  Future<void> _onActionSelected(String action) async {
    if (!mounted) return;
    if (action == 'Track Workout') {
      // On Android, request ACTIVITY_RECOGNITION at runtime.
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.activityRecognition.request();
        if (!(status.isGranted || status.isLimited)) {
          if (!mounted) return;
          final double screenWidth = MediaQuery.sizeOf(context).width;
          final double hMargin =
              screenWidth > 392 ? (screenWidth - 360) / 2 : 16;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permission required to track workouts.'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                left: hMargin,
                right: hMargin,
                bottom: MediaQuery.viewPaddingOf(context).bottom + 86,
              ),
            ),
          );
          return;
        }
      }
      if (!mounted) return;
      setState(() => _expanded = false);
      widget.dimmer?.value = false;
      // Navigate and wait
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const TrackWorkoutScreen()));
      if (!mounted) return;
      widget.dimmer?.value = false;
      setState(() {}); // Refresh list to reflect newly saved workout
      return;
    }
    if (action == 'Log Water') {
      setState(() => _expanded = false);
      widget.dimmer?.value = false;
      if (!mounted) return;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LogWaterScreen()));
      if (!mounted) return;
      widget.dimmer?.value = false;
      return;
    }
    if (action == 'Log Food') {
      setState(() => _expanded = false);
      widget.dimmer?.value = false;
      if (!mounted) return;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LogFoodScreen()));
      if (!mounted) return;
      widget.dimmer?.value = false;
      return;
    }
    if (action == 'Track Sleep') {
      setState(() => _expanded = false);
      widget.dimmer?.value = false;
      if (!mounted) return;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const TrackSleepScreen()));
      if (!mounted) return;
      widget.dimmer?.value = false;
      return;
    }
    // Other actions placeholder
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double hMargin = screenWidth > 392 ? (screenWidth - 360) / 2 : 16;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          left: hMargin,
          right: hMargin,
          bottom: MediaQuery.viewPaddingOf(context).bottom + 86,
        ),
      ),
    );
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    // One-time subscribe to global dimmer so we can collapse when overlay is cleared
    _dimmerSub ??= () {
      if (widget.dimmer?.value == false && _expanded == true) {
        setState(() => _expanded = false);
      }
    };
    if (widget.dimmer != null) {
      widget.dimmer!.removeListener(_dimmerSub!);
      widget.dimmer!.addListener(_dimmerSub!);
    }
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    const double spacing = 12;
    final bool isExpanded = _expanded == true;
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tileBg = (isDark
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

    // Build floating layer (FAB + menu) so it can be rendered above the dim overlay
    final Widget floating = Positioned(
      right: 16,
      bottom: 16 +
          viewPadding.bottom +
          (MediaQuery.sizeOf(context).width < 650 ? 0 : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) {
              return FadeTransition(
                opacity: anim,
                child: SizeTransition(
                  sizeFactor: anim,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: !isExpanded
                ? const SizedBox.shrink()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StaggeredOption(
                        delay: 0,
                        child: FilledButton.tonalIcon(
                          style: pillStyle,
                          onPressed: () => _onActionSelected('Track Workout'),
                          icon: const Icon(Icons.directions_walk),
                          label: const Text('Track Workout'),
                        ),
                      ),
                      const SizedBox(height: spacing),
                      _StaggeredOption(
                        delay: 50,
                        child: FilledButton.tonalIcon(
                          style: pillStyle,
                          onPressed: () => _onActionSelected('Log Food'),
                          icon: const Icon(Icons.restaurant),
                          label: const Text('Log Food'),
                        ),
                      ),
                      const SizedBox(height: spacing),
                      _StaggeredOption(
                        delay: 100,
                        child: FilledButton.tonalIcon(
                          style: pillStyle,
                          onPressed: () => _onActionSelected('Track Sleep'),
                          icon: const Icon(Icons.nightlight_round),
                          label: const Text('Track Sleep'),
                        ),
                      ),
                      const SizedBox(height: spacing),
                      _StaggeredOption(
                        delay: 150,
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
            onPressed: () {
              final next = !(isExpanded);
              setState(() => _expanded = next);
              widget.dimmer?.value = next;
            },
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
    );

    // Publish floating layer to root so it renders above global dim overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.floatingLayer?.value = floating;
    });

    // Ensure floating layer is cleared when screen disposes
    // (so it doesn't persist if user navigates away)

    return WillPopScope(
      onWillPop: () async {
        if (_selectionMode) {
          setState(() {
            _selectionMode = false;
            _selectedIds.clear();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: _selectionMode
              ? Text('${_selectedIds.length} selected')
              : const Text('Activity'),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: const FrostedBarBackground(),
          leading: _selectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectionMode = false;
                      _selectedIds.clear();
                    });
                  },
                )
              : null,
          actions: _selectionMode
              ? [
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () async {
                            final bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: Text(
                                      'Delete ${_selectedIds.length} item(s)?'),
                                  content: const Text(
                                      'This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirm == true) {
                              final List<String> ids = _selectedIds.toList();
                              for (final id in ids) {
                                final _ActivityItem? item = _idToItem[id];
                                if (item == null) continue;
                                if (item.type == _ActivityType.workout) {
                                  await WorkoutStore.instance
                                      .delete(item.workout!);
                                } else if (item.type == _ActivityType.water) {
                                  await WaterStore.instance.delete(item.water!);
                                } else if (item.type == _ActivityType.food) {
                                  await FoodStore.instance.delete(item.food!);
                                } else if (item.type == _ActivityType.sleep) {
                                  await SleepStore.instance.delete(item.sleep!);
                                }
                              }
                              if (!mounted) return;
                              setState(() {
                                _selectedIds.clear();
                                _selectionMode = false;
                              });
                            }
                          },
                  ),
                  const SizedBox(width: 8),
                ]
              : null,
        ),
        body: Stack(
          children: [
            // Combined activities: workouts and water logs
            _ActivityFeed(
              tileBg: tileBg,
              outline: outline,
              selectionMode: _selectionMode,
              selectedIds: _selectedIds,
              onToggleSelect: (id, item) {
                setState(() {
                  _idToItem[id] = item;
                  if (!_selectionMode) {
                    _selectionMode = true;
                  }
                  if (_selectedIds.contains(id)) {
                    _selectedIds.remove(id);
                    if (_selectedIds.isEmpty) _selectionMode = false;
                  } else {
                    _selectedIds.add(id);
                  }
                });
              },
            ),
            // Dim background when menu is expanded and close on tap
            // Removed local overlay; using global dimmer from RootNav
            // Floating layer is published to root; nothing else here
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_dimmerSub != null && widget.dimmer != null) {
      widget.dimmer!.removeListener(_dimmerSub!);
    }
    widget.floatingLayer?.value = null;
    widget.dimmer?.value = false;
    super.dispose();
  }
}

class _StaggeredOption extends StatefulWidget {
  const _StaggeredOption({required this.child, required this.delay});

  final Widget child;
  final int delay; // ms

  @override
  State<_StaggeredOption> createState() => _StaggeredOptionState();
}

class _StaggeredOptionState extends State<_StaggeredOption> {
  bool _start = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: widget.delay), () {
      if (!mounted) return;
      setState(() => _start = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _start ? 1 : 0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 10),
          child: Opacity(opacity: value, child: widget.child),
        );
      },
      child: widget.child,
    );
  }
}

class _ActivityItem {
  _ActivityItem.workout(Workout w)
      : workout = w,
        water = null,
        food = null,
        sleep = null,
        type = _ActivityType.workout,
        time = w.startedAt;
  _ActivityItem.water(WaterLog l)
      : water = l,
        workout = null,
        food = null,
        sleep = null,
        type = _ActivityType.water,
        time = l.loggedAt;
  _ActivityItem.food(FoodLog f)
      : food = f,
        workout = null,
        water = null,
        sleep = null,
        type = _ActivityType.food,
        time = f.loggedAt;
  _ActivityItem.sleep(SleepLog s)
      : sleep = s,
        workout = null,
        water = null,
        food = null,
        type = _ActivityType.sleep,
        time = s.endTime;

  final _ActivityType type;
  final Workout? workout;
  final WaterLog? water;
  final FoodLog? food;
  final SleepLog? sleep;
  final DateTime time;
}

enum _ActivityType { workout, water, food, sleep }

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({
    required this.tileBg,
    required this.outline,
    this.selectionMode = false,
    this.selectedIds,
    this.onToggleSelect,
  });

  final Color tileBg;
  final Color outline;
  final bool selectionMode;
  final Set<String>? selectedIds;
  final void Function(String id, _ActivityItem item)? onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final listenableWorkout = WorkoutStore.instance.listenable!;
    final listenableWater = WaterStore.instance.listenable!;
    return ValueListenableBuilder(
      valueListenable: listenableWorkout,
      builder: (context, Box<Workout> wBox, _) {
        return ValueListenableBuilder(
          valueListenable: listenableWater,
          builder: (context, Box<WaterLog> waterBox, __) {
            final listenableFood = FoodStore.instance.listenable!;
            return ValueListenableBuilder(
              valueListenable: listenableFood,
              builder: (context, Box<FoodLog> foodBox, ___) {
                final listenableSleep = SleepStore.instance.listenable!;
                return ValueListenableBuilder(
                  valueListenable: listenableSleep,
                  builder: (context, Box<SleepLog> sleepBox, ____) {
                    final List<_ActivityItem> items = <_ActivityItem>[
                      ...wBox.values.toList().cast<Workout>().map(
                            (w) => _ActivityItem.workout(w),
                          ),
                      ...waterBox.values.toList().cast<WaterLog>().map(
                            (l) => _ActivityItem.water(l),
                          ),
                      ...foodBox.values.toList().cast<FoodLog>().map(
                            (f) => _ActivityItem.food(f),
                          ),
                      ...sleepBox.values.toList().cast<SleepLog>().map(
                            (s) => _ActivityItem.sleep(s),
                          ),
                    ]..sort((a, b) => b.time.compareTo(a.time));

                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: 120,
                        left: 16,
                        right: 16,
                        top: 8,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final _ActivityItem item = items[index];
                        if (item.type == _ActivityType.workout) {
                          final Workout w = item.workout!;
                          final String hh =
                              w.elapsed.inHours.toString().padLeft(2, '0');
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
                          final String min = dt.minute.toString().padLeft(
                                2,
                                '0',
                              );
                          final String meridiem = dt.hour < 12 ? 'AM' : 'PM';
                          final String time12 =
                              '${hr12.toString().padLeft(2, '0')}:$min $meridiem';
                          final String id =
                              'w_${w.startedAt.millisecondsSinceEpoch}';
                          final bool isSelected =
                              selectedIds?.contains(id) == true;
                          return GestureDetector(
                            onLongPress: () => onToggleSelect?.call(id, item),
                            onTap: selectionMode
                                ? () => onToggleSelect?.call(id, item)
                                : null,
                            child: Card(
                              color: tileBg,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : outline.withValues(alpha: 0.6),
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.directions_walk),
                                title: Text(w.activity),
                                subtitle: Text(
                                  'Time: $hh:$mm:$ss  •  Steps: ${w.steps}',
                                ),
                                trailing: Text(time12),
                              ),
                            ),
                          );
                        } else if (item.type == _ActivityType.water) {
                          final WaterLog l = item.water!;
                          final DateTime dt = l.loggedAt;
                          final int rawH = dt.hour % 12;
                          final int hr12 = rawH == 0 ? 12 : rawH;
                          final String min = dt.minute.toString().padLeft(
                                2,
                                '0',
                              );
                          final String meridiem = dt.hour < 12 ? 'AM' : 'PM';
                          final String time12 =
                              '${hr12.toString().padLeft(2, '0')}:$min $meridiem';
                          final String id =
                              'wa_${l.loggedAt.millisecondsSinceEpoch}_${l.amountMl}';
                          final bool isSelected =
                              selectedIds?.contains(id) == true;
                          return GestureDetector(
                            onLongPress: () => onToggleSelect?.call(id, item),
                            onTap: selectionMode
                                ? () => onToggleSelect?.call(id, item)
                                : null,
                            child: Card(
                              color: tileBg,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : outline.withValues(alpha: 0.6),
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.water_drop),
                                title: const Text('Water'),
                                subtitle: Text('Added: ${l.amountMl} ml'),
                                trailing: Text(time12),
                              ),
                            ),
                          );
                        } else if (item.type == _ActivityType.food) {
                          final FoodLog f = item.food!;
                          final DateTime dt = f.loggedAt;
                          final int rawH = dt.hour % 12;
                          final int hr12 = rawH == 0 ? 12 : rawH;
                          final String min = dt.minute.toString().padLeft(
                                2,
                                '0',
                              );
                          final String meridiem = dt.hour < 12 ? 'AM' : 'PM';
                          final String time12 =
                              '${hr12.toString().padLeft(2, '0')}:$min $meridiem';
                          final String id =
                              'f_${f.loggedAt.millisecondsSinceEpoch}_${f.name}';
                          final bool isSelected =
                              selectedIds?.contains(id) == true;
                          return GestureDetector(
                            onLongPress: () => onToggleSelect?.call(id, item),
                            onTap: selectionMode
                                ? () => onToggleSelect?.call(id, item)
                                : null,
                            child: Card(
                              color: tileBg,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : outline.withValues(alpha: 0.6),
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.restaurant),
                                title: Text(f.name),
                                subtitle: Text(
                                  (f.details == null || f.details!.isEmpty)
                                      ? 'Amount: ${f.quantity} ${f.unit}'
                                      : f.details!,
                                ),
                                trailing: Text(time12),
                              ),
                            ),
                          );
                        } else {
                          final SleepLog s = item.sleep!;
                          final String hh =
                              s.duration.inHours.toString().padLeft(2, '0');
                          final String mm = s.duration.inMinutes
                              .remainder(60)
                              .toString()
                              .padLeft(2, '0');
                          final DateTime dt = s.endTime;
                          final int rawH = dt.hour % 12;
                          final int hr12 = rawH == 0 ? 12 : rawH;
                          final String min = dt.minute.toString().padLeft(
                                2,
                                '0',
                              );
                          final String meridiem = dt.hour < 12 ? 'AM' : 'PM';
                          final String time12 =
                              '${hr12.toString().padLeft(2, '0')}:$min $meridiem';
                          final String id =
                              's_${s.endTime.millisecondsSinceEpoch}_${s.duration.inMinutes}';
                          final bool isSelected =
                              selectedIds?.contains(id) == true;
                          return GestureDetector(
                            onLongPress: () => onToggleSelect?.call(id, item),
                            onTap: selectionMode
                                ? () => onToggleSelect?.call(id, item)
                                : null,
                            child: Card(
                              color: tileBg,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : outline.withValues(alpha: 0.6),
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.nightlight_round),
                                title: const Text('Sleep'),
                                subtitle: Text('Duration: ${hh}h ${mm}m'),
                                trailing: Text(time12),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ConfirmDeleteSheet extends StatelessWidget {
  const _ConfirmDeleteSheet({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
