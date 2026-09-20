import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:babyblue/core/constants.dart';
import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/mood_tracker/data/models/mood_entry.dart';

/// Displays a single mood entry as a compact, styled card.
///
/// Shows the mood emoji, score label, timestamp, and optional note.
/// A coloured left accent strip indicates the mood level at a glance.
class MoodHistoryCard extends StatelessWidget {
  final MoodEntry entry;

  /// Optional callback when the user long-presses to delete.
  final VoidCallback? onDelete;

  const MoodHistoryCard({
    super.key,
    required this.entry,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodIndex = (entry.moodScore - 1).clamp(0, 4);
    final color = AppTheme.moodColors[moodIndex];
    final emoji = AppConstants.moodEmojis[moodIndex];
    final label = AppConstants.moodLabels[moodIndex];
    final timeStr = DateFormat('MMM d · h:mm a').format(entry.timestamp);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.errorRed, size: 24),
      ),
      child: Card(
        child: IntrinsicHeight(
          child: Row(
            children: [
              // ── Colour accent strip ──────────────────────────
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Emoji ────────────────────────────────────────
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),

              // ── Text content ─────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label + time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      // Note preview (if present).
                      if (entry.note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}
