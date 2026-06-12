import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'data/services/database_service.dart';
import 'theme.dart';

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri != null && uri.scheme == 'aadat' && uri.host == 'checkin') {
    final habitIdStr = uri.queryParameters['id'];
    if (habitIdStr != null) {
      final habitId = int.tryParse(habitIdStr);
      if (habitId != null) {
        final dbService = await DatabaseService.getInstance();
        final habit = await dbService.getHabitById(habitId);
        if (habit != null) {
          final todayLog = await dbService.getTodayLog(habitId);
          final currentCount = todayLog?.completionCount ?? 0;
          final completed = currentCount >= habit.timesPerDay;
          final targetCount = completed ? 0 : habit.timesPerDay;
          await dbService.setTodayCompletion(habitId, targetCount);
          await DatabaseService.updateWidgetDataFromDb();
        }
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerInteractivityCallback(backgroundCallback);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()..init()),
      ],
      child: const AadatApp(),
    ),
  );
}

class AadatApp extends StatelessWidget {
  const AadatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Aadat',
      debugShowCheckedModeBanner: false,
      theme: InkTheme.theme,
      darkTheme: InkTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AppHome(),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    if (!themeProvider.preferencesLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5),
        ),
      );
    }

    if (themeProvider.userName.isEmpty) {
      return OnboardingScreen(
        onComplete: (name) {},
      );
    }

    return const MainShell();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    ArchiveScreen(),
    ProfileScreen(),
  ];

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: _AadatNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _AadatNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AadatNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(icon: Icons.book_outlined, activeIcon: Icons.book, label: 'Journal'),
      _NavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: 'Stats'),
      _NavItem(icon: Icons.inbox_outlined, activeIcon: Icons.inbox, label: 'Archive'),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: isSelected ? onSurfaceColor : surfaceColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 22,
                          color: isSelected ? surfaceColor : onSurfaceColor,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: isSelected ? surfaceColor : onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
