import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aadat/providers/theme_provider.dart';
import 'package:aadat/screens/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding screen renders and displays prompt', (WidgetTester tester) async {
    // Mock SharedPreferences for ThemeProvider
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider();

    // Pump only OnboardingScreen inside ThemeProvider to bypass HabitProvider's SQLite database initialization
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: themeProvider,
        child: const MaterialApp(
          home: OnboardingScreen(
            onComplete: _dummyOnComplete,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the prompt text is present
    expect(find.text('WHAT SHOULD WE CALL YOU?'), findsOneWidget);
  });
}

void _dummyOnComplete(String name) {}
