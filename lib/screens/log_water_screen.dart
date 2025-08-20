import 'package:flutter/material.dart';
import '../state/water_store.dart';
import '../models/water_log.dart';

class LogWaterScreen extends StatefulWidget {
  const LogWaterScreen({super.key});

  @override
  State<LogWaterScreen> createState() => _LogWaterScreenState();
}

class _LogWaterScreenState extends State<LogWaterScreen>
    with SingleTickerProviderStateMixin {
  int _totalMl = 0;
  late final AnimationController _fillCtl;
  late final Animation<double> _fillAnim; // 0 → 1 → 0 pulse

  @override
  void initState() {
    super.initState();
    _fillCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fillAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _fillCtl, curve: Curves.easeInOut));
  }

  void _pulseFill() {
    _fillCtl.forward(from: 0);
  }

  void _addWater(int ml) {
    setState(() => _totalMl += ml);
    _pulseFill();
  }

  Future<void> _addCustom() async {
    final TextEditingController ctrl = TextEditingController();
    final int? result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom amount'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter amount (ml)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final int? ml = int.tryParse(ctrl.text.trim());
                if (ml != null && ml > 0) {
                  Navigator.pop<int>(context, ml);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      _addWater(result);
    }
  }

  void _save() {
    if (_totalMl <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add water before saving.')),
      );
      return;
    }
    WaterStore.instance.add(
      WaterLog(amountMl: _totalMl, loggedAt: DateTime.now()),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved ${_totalMl} ml')));
    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _fillCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Log Water')),
      body: Column(
        children: [
          // Top half box similar to Track Workout
          SizedBox(
            height: 340,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                color: scheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hydration',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('Today'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Animated glass fill
                                SizedBox(
                                  width: 90,
                                  height: 120,
                                  child: AnimatedBuilder(
                                    animation: _fillAnim,
                                    builder: (context, _) {
                                      return Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          // Water fill
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: 70,
                                              height: 100 * _fillAnim.value,
                                              decoration: BoxDecoration(
                                                color: scheme.primary
                                                    .withValues(alpha: 0.65),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                      topLeft: Radius.circular(
                                                        6,
                                                      ),
                                                      topRight: Radius.circular(
                                                        6,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          // Glass outline + icon hint
                                          Container(
                                            width: 70,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: scheme.outline,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  '${_totalMl} ml',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'added today',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom half controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _VolumeTile(
                          label: '250 ml',
                          icon: Icons.local_drink, // glass
                          onAdd: () => _addWater(250),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _VolumeTile(
                          label: '500 ml',
                          icon: Icons.sports_bar, // bottle/mug
                          onAdd: () => _addWater(500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _VolumeTile(
                          label: '1000 ml',
                          icon: Icons.water, // big bottle/drop
                          onAdd: () => _addWater(1000),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _VolumeTile(
                          label: 'Custom',
                          icon: Icons.edit,
                          onAdd: _addCustom,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: const Size.fromHeight(66),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                    ),
                    child: Text(
                      'Save',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
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
}

class _VolumeTile extends StatelessWidget {
  const _VolumeTile({required this.label, required this.onAdd, this.icon});

  final String label;
  final VoidCallback onAdd;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: scheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon ?? Icons.local_drink, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
