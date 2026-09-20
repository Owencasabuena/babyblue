import 'package:flutter/material.dart';

import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/journal/data/models/journal_mood.dart';

/// Horizontal scrollable row of mood pills for the journal.
///
/// The selected pill gets a filled background with a subtle scale.
/// Tapping a pill calls [onMoodSelected] with the chosen [JournalMood].
class MoodSelector extends StatelessWidget {
  /// Currently selected mood, or `null` if none.
  final JournalMood? selected;

  /// Called when the user taps a mood pill.
  final ValueChanged<JournalMood> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selected,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: JournalMoods.all.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mood = JournalMoods.all[index];
          final isSelected = mood == selected;

          return GestureDetector(
            onTap: () => onMoodSelected(mood),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryLavender
                    : AppTheme.primaryLight.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryLavender
                      : AppTheme.primaryLight.withAlpha(60),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mood.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    mood.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          isSelected ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
