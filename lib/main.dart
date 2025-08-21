import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'screens/dashboard_screen.dart';
import 'screens/activity_screen.dart';
import 'package:flutter/services.dart';
import 'state/workout_store.dart';
import 'state/water_store.dart';
import 'state/food_store.dart';
import 'state/user_store.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/frosted.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  runApp(const Boot());
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> {
  late final Future<void> _init = _initAll();

  Future<void> _initAll() async {
    await WorkoutStore.instance.init();
    await UserStore.instance.init();
    await WaterStore.instance.init();
    await FoodStore.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(home: SizedBox());
        }
        return const MyApp();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final Color seed = Colors.teal;
        final ColorScheme lightScheme =
            lightDynamic ?? ColorScheme.fromSeed(seedColor: seed);
        final ColorScheme darkScheme =
            darkDynamic ??
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);

        return MaterialApp(
          title: 'HealthVerse',
          theme: ThemeData(useMaterial3: true, colorScheme: lightScheme),
          darkTheme: ThemeData(useMaterial3: true, colorScheme: darkScheme),
          themeMode: ThemeMode.system,
          routes: {'/dashboard': (_) => const RootNav()},
          home: UserStore.instance.profile == null
              ? const OnboardingScreen()
              : const RootNav(),
        );
      },
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [DashboardScreen(), ActivityScreen()];

  List<NavigationDestination> get _navDestinations => const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.history),
      selectedIcon: Icon(Icons.history),
      label: 'Activity',
    ),
  ];

  List<NavigationRailDestination> get _railDestinations => const [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.history),
      selectedIcon: Icon(Icons.history),
      label: Text('Activity'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          // Desktop: extended rail with header
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: FrostedWrap(
                    child: NavigationRail(
                      extended: true,
                      backgroundColor: Colors.transparent,
                      leading: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/icons/app_icon_dark.png',
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    const Icon(
                                      Icons.health_and_safety,
                                      size: 24,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'HealthVerse',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      selectedIndex: _currentIndex,
                      onDestinationSelected: (i) =>
                          setState(() => _currentIndex = i),
                      labelType: NavigationRailLabelType.none,
                      destinations: _railDestinations,
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          );
        } else if (constraints.maxWidth >= 650) {
          // Tablet: compact rail with labels
          return _buildRailScaffold(context, extended: false);
        }
        // Mobile: bottom navigation bar
        return _buildBottomScaffold(context);
      },
    );
  }

  Widget _buildBottomScaffold(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: FrostedWrap(
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: _navDestinations,
        ),
      ),
    );
  }

  Widget _buildRailScaffold(BuildContext context, {required bool extended}) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: FrostedWrap(
              child: NavigationRail(
                extended: extended,
                selectedIndex: _currentIndex,
                onDestinationSelected: (i) => setState(() => _currentIndex = i),
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                destinations: _railDestinations,
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
    );
  }
}
