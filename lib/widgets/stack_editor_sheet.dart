import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/models/habit.dart';
import '../data/models/habit_stack.dart';
import '../providers/habit_provider.dart';

class StackEditorSheet extends StatefulWidget {
  final HabitStack? stack;
  const StackEditorSheet({super.key, this.stack});

  @override
  State<StackEditorSheet> createState() => _StackEditorSheetState();
}

class _StackEditorSheetState extends State<StackEditorSheet> {
  final _nameController = TextEditingController();
  List<int> _selectedIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.stack != null) {
      _nameController.text = widget.stack!.name;
      _selectedIds = List<int>.from(widget.stack!.habitIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveStack() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a stack name',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add at least one habit to the stack',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final provider = context.read<HabitProvider>();
    if (widget.stack == null) {
      provider.createStack(name, _selectedIds);
    } else {
      provider.updateStack(widget.stack!.copyWith(name: name, habitIds: _selectedIds));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final outlineColor = isDark ? const Color(0xFF444444) : const Color(0xFFDDDDDD);

    final provider = context.watch<HabitProvider>();
    final allActiveHabits = provider.activeHabits;

    // Filter to get resolved list of selected habits in correct order
    final selectedHabits = _selectedIds
        .map((id) {
          for (final h in allActiveHabits) {
            if (h.id == id) return h;
          }
          return null;
        })
        .whereType<Habit>()
        .toList();

    // Available standalone habits (standalone OR already in this stack if editing)
    final availableHabits = allActiveHabits.where((h) {
      if (_selectedIds.contains(h.id)) return false;
      final parentStack = provider.getStackForHabit(h.id!);
      return parentStack == null || parentStack.id == widget.stack?.id;
    }).toList();

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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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
                widget.stack == null ? 'New Stack' : 'Edit Stack',
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
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stack Name Input
                  Text(
                    'STACK NAME',
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
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: onSurfaceColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Morning Routine',
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

                  // Habits in stack (Drag to reorder)
                  Text(
                    'HABITS IN STACK (DRAG TO REORDER)',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (selectedHabits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                      child: Text(
                        'No habits added to this stack yet. Tap available habits below.',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFF888888),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: outlineColor, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: selectedHabits.length,
                        onReorder: (oldIdx, newIdx) {
                          setState(() {
                            if (newIdx > oldIdx) {
                              newIdx -= 1;
                            }
                            final item = _selectedIds.removeAt(oldIdx);
                            _selectedIds.insert(newIdx, item);
                          });
                        },
                        itemBuilder: (context, idx) {
                          final habit = selectedHabits[idx];
                          return ListTile(
                            key: ValueKey<int>(habit.id!),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                            leading: Icon(Icons.drag_handle, color: onSurfaceColor, size: 20),
                            title: Text(
                              habit.name,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: onSurfaceColor,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _selectedIds.remove(habit.id);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 28),

                  // Available habits list
                  Text(
                    'AVAILABLE STANDALONE HABITS',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (availableHabits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                      child: Text(
                        'No other standalone habits available.',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFF888888),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: outlineColor, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: availableHabits.length,
                        separatorBuilder: (_, __) => Divider(color: outlineColor, height: 1),
                        itemBuilder: (context, idx) {
                          final habit = availableHabits[idx];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                            title: Text(
                              habit.name,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: onSurfaceColor,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _selectedIds.add(habit.id!);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE)),
          const SizedBox(height: 16),

          // CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saveStack,
              style: ElevatedButton.styleFrom(
                backgroundColor: onSurfaceColor,
                foregroundColor: surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.stack == null ? '✏  CREATE STACK' : '✏  SAVE CHANGES',
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
    );
  }
}
