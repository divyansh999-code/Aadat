import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(
              'PREFERENCES',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: isDark ? const Color(0xFFAAAAAA) : const Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(
                  'Dark Mode',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Switch between light and dark journal themes',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF888888) : const Color(0xFF888888),
                  ),
                ),
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    HapticFeedback.mediumImpact();
                    themeProvider.toggleTheme(val);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
