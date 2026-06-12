import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/habit.dart';

class AddHabitSheet extends StatefulWidget {
  final Habit? habit;
  const AddHabitSheet({super.key, this.habit});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _nameController = TextEditingController();
  List<int> _selectedDays = []; // empty = every day
  int _timesPerDay = 1;
  bool _strictMode = false;
  bool _isEveryDay = true;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _selectedDays = List<int>.from(widget.habit!.targetDaysOfWeek);
      _isEveryDay = _selectedDays.isEmpty;
      _timesPerDay = widget.habit!.timesPerDay;
      _strictMode = widget.habit!.strictMode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleDay(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedDays.contains(index)) {
        _selectedDays.remove(index);
      } else {
        _selectedDays.add(index);
      }
      _isEveryDay = _selectedDays.isEmpty;
    });
  }

  void _toggleEveryday() {
    HapticFeedback.selectionClick();
    setState(() {
      _isEveryDay = !_isEveryDay;
      if (_isEveryDay) {
        _selectedDays = [];
      } else {
        // Select all days
        _selectedDays = List.generate(7, (i) => i);
      }
    });
  }

  void _createHabit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a habit name',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final habit = widget.habit != null
        ? widget.habit!.copyWith(
            name: name,
            targetDaysOfWeek: _isEveryDay ? [] : List<int>.from(_selectedDays),
            timesPerDay: _timesPerDay,
            strictMode: _strictMode,
          )
        : Habit(
            name: name,
            targetDaysOfWeek: _isEveryDay ? [] : List<int>.from(_selectedDays),
            timesPerDay: _timesPerDay,
            strictMode: _strictMode,
            isArchived: false,
            createdAt: DateTime.now(),
          );

    Navigator.of(context).pop(habit);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final outlineColor = isDark ? const Color(0xFF444444) : const Color(0xFFDDDDDD);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: outlineColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Habit',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: onSurfaceColor, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.close, size: 16, color: onSurfaceColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Habit Name
            Text(
              'HABIT NAME',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: onSurfaceColor,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Read 10 pages',
                hintStyle: GoogleFonts.dmSans(
                  color: isDark ? const Color(0xFF666666) : const Color(0xFFAAAAAA),
                  fontSize: 14,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: outlineColor, width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: outlineColor, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: onSurfaceColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 28),

            // Repeat Days
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REPEAT DAYS',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: onSurfaceColor,
                  ),
                ),
                GestureDetector(
                  onTap: _toggleEveryday,
                  child: Text(
                    'Everyday',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isEveryDay ? onSurfaceColor : const Color(0xFF888888),
                      decoration:
                          _isEveryDay ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final isSelected = _isEveryDay || _selectedDays.contains(i);
                return GestureDetector(
                  onTap: () => _toggleDay(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? onSurfaceColor : surfaceColor,
                      border: Border.all(
                        color: isSelected ? onSurfaceColor : outlineColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        _dayLabels[i],
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? surfaceColor : onSurfaceColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // Times Per Day
            Text(
              'TIMES PER DAY',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: outlineColor, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  _StepperButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_timesPerDay > 1) {
                        HapticFeedback.selectionClick();
                        setState(() => _timesPerDay--);
                      }
                    },
                    outlineColor: outlineColor,
                    color: onSurfaceColor,
                  ),
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: Text(
                          '$_timesPerDay',
                          key: ValueKey<int>(_timesPerDay),
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add,
                    onTap: () {
                      if (_timesPerDay < 20) {
                        HapticFeedback.selectionClick();
                        setState(() => _timesPerDay++);
                      }
                    },
                    outlineColor: outlineColor,
                    color: onSurfaceColor,
                    isRight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Strict Mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STRICT MODE',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Fail habit if missed for a single day.',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: isDark ? const Color(0xFFAAAAAA) : const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _strictMode,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _strictMode = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            // CTA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _createHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onSurfaceColor,
                  foregroundColor: surfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.habit != null ? '✏  SAVE CHANGES' : '✏  CREATE HABIT',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: surfaceColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color outlineColor;
  final Color color;
  final bool isRight;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.outlineColor,
    required this.color,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          border: isRight
              ? Border(
                  left: BorderSide(color: outlineColor, width: 1),
                )
              : Border(
                  right: BorderSide(color: outlineColor, width: 1),
                ),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
