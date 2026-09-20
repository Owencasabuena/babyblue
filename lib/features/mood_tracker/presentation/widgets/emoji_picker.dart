import 'package:flutter/material.dart';

import 'package:babyblue/core/constants.dart';
import 'package:babyblue/core/theme/app_theme.dart';

/// An interactive 1–5 emoji scale for selecting a mood score.
///
/// Each emoji is displayed inside a circular container with the
/// corresponding mood label beneath it. The selected emoji smoothly
/// animates to a larger size with a coloured background.
class EmojiPicker extends StatelessWidget {
  /// Currently selected mood score (1-based), or `null` if none.
  final int? selectedScore;

  /// Callback fired when the user taps an emoji.
  /// Receives a 1-based mood score.
  final ValueChanged<int> onSelect;

  const EmojiPicker({
    super.key,
    required this.selectedScore,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final score = index + 1; // 1-based score.
        final isSelected = selectedScore == score;
        final color = AppTheme.moodColors[index];

        return GestureDetector(
          onTap: () => onSelect(score),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(isSelected ? 4 : 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Emoji Circle ───────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  width: isSelected ? 64 : 52,
                  height: isSelected ? 64 : 52,
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(51) : Colors.grey.withAlpha(26),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: isSelected ? 2.5 : 0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withAlpha(64),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(fontSize: isSelected ? 30 : 24),
                      child: Text(AppConstants.moodEmojis[index]),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // ── Label ──────────────────────────────────────
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? color : AppTheme.textMuted,
                  ),
                  child: Text(AppConstants.moodLabels[index]),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
