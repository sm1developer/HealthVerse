import 'dart:io';

import 'package:flutter/material.dart';
import '../state/user_store.dart';
import '../widgets/frosted.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final int h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    if (h < 21) return 'Good evening,';
    return 'Good night,';
  }

  @override
  Widget build(BuildContext context) {
    final profile = UserStore.instance.profile;
    final String name = profile?.name ?? 'User';
    final String? photo = profile?.photoPath;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    Color blend(Color base, Color overlay, double t) =>
        Color.lerp(base, overlay, t)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const FrostedBarBackground(),
        titleSpacing: 16,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
        ],
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: (photo != null && File(photo).existsSync())
                  ? FileImage(File(photo))
                  : null,
              child: (photo == null || !File(photo).existsSync())
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(name, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          12,
          8,
          12,
          20 + MediaQuery.viewPaddingOf(context).bottom + 80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row: Heart Rate & Steps
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    color: blend(scheme.surface, scheme.errorContainer, 0.25),
                    icon: Icons.favorite,
                    iconColor: scheme.onErrorContainer,
                    title: 'Heart Rate',
                    primaryValue: '78',
                    secondary: 'bpm',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    color: blend(scheme.surface, scheme.primaryContainer, 0.25),
                    icon: Icons.directions_walk,
                    iconColor: scheme.onPrimaryContainer,
                    title: 'Steps',
                    primaryValue: '10,234',
                    secondary: 'today',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Sleep wide card
            _SleepCard(
              color: blend(scheme.surface, scheme.secondaryContainer, 0.18),
            ),
            const SizedBox(height: 12),
            // Second row: Calories & Water
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    color: blend(
                      scheme.surface,
                      scheme.tertiaryContainer,
                      0.22,
                    ),
                    icon: Icons.local_fire_department,
                    iconColor: scheme.onTertiaryContainer,
                    title: 'Calories',
                    primaryValue: '1,800',
                    secondary: '/ 2,500 kcal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    color: blend(
                      scheme.surface,
                      scheme.secondaryContainer,
                      0.22,
                    ),
                    icon: Icons.opacity,
                    iconColor: scheme.onSecondaryContainer,
                    title: 'Water',
                    primaryValue: '6',
                    secondary: '/ 8 glasses',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Third row: Workout & Weight
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    color: blend(scheme.surface, scheme.errorContainer, 0.20),
                    icon: Icons.directions_walk,
                    iconColor: scheme.onErrorContainer,
                    title: 'Workout',
                    primaryValue: '45',
                    secondary: 'min',
                    footer: 'Cardio',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    color: blend(scheme.surface, Colors.green.shade700, 0.18),
                    icon: Icons.monitor_weight,
                    iconColor: Colors.white,
                    title: 'Weight',
                    primaryValue: '154',
                    secondary: 'lbs',
                    footer: '-1.2 lbs this week',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.primaryValue,
    this.secondary,
    this.footer,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String primaryValue;
  final String? secondary;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final onColor = _onColorFor(color, Theme.of(context).colorScheme);
    return Card(
      color: color,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: onColor.withValues(alpha: 0.12),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: onColor),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      primaryValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: onColor,
                          ),
                    ),
                  ),
                  if (secondary != null) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          secondary!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          textAlign: TextAlign.start,
                          style:
                              TextStyle(color: onColor.withValues(alpha: 0.9)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (footer != null) ...[
                const SizedBox(height: 6),
                Text(
                  footer!,
                  style: TextStyle(color: onColor.withValues(alpha: 0.9)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _onColorFor(Color bg, ColorScheme scheme) {
    final double luminance = bg.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

class _SleepCard extends StatelessWidget {
  const _SleepCard({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final onColor = _onColorFor(color);
    return Card(
      color: color,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: onColor.withValues(alpha: 0.12),
                    child: Icon(Icons.nightlight_round, color: onColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sleep',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: onColor),
                        ),
                        Text(
                          '7h 30m last night',
                          style: TextStyle(
                            color: onColor.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: onColor),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 7.5 / 8.0,
                  minHeight: 8,
                  backgroundColor: onColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(onColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _onColorFor(Color bg) =>
      bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
