import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/journal/data/models/journal_entry.dart';

/// A card displaying a journal entry in the timeline feed.
///
/// Two visual variants:
/// - **Full** (`compact: false`): mood icon, time, full content, gratitude
///   pills, and edit/delete actions. Used for "Today" entries.
/// - **Compact** (`compact: true`): mood icon, timestamp, 1-line snippet,
///   and optional mini gratitude pills. Used for "Yesterday" and "Past 7 Days".
class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;

  /// If true, renders the compact variant.
  final bool compact;

  /// Called when the user taps the edit action (full variant only).
  final VoidCallback? onEdit;

  /// Called when the user taps the delete action.
  final VoidCallback? onDelete;

  const JournalEntryCard({
    super.key,
    required this.entry,
    this.compact = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('h:mm a').format(entry.createdAt);

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryLight.withAlpha(45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLavender.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: compact ? _buildCompact(theme, timeStr) : _buildFull(theme, timeStr),
    );
  }

  // ── Full variant (Today) ────────────────────────────────────────

  Widget _buildFull(ThemeData theme, String timeStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: mood + time + actions.
        Row(
          children: [
            Text(entry.mood.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.mood.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  timeStr,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
            const Spacer(),
            // Input type badge.
            if (entry.inputType == 'voice')
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_rounded,
                        size: 12, color: AppTheme.primaryLavender),
                    SizedBox(width: 3),
                    Text(
                      'Voice',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLavender,
                      ),
                    ),
                  ],
                ),
              ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: AppTheme.textMuted,
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: AppTheme.textMuted.withAlpha(150),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Content.
        Text(
          entry.content,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),

        // Gratitude pills.
        if (entry.gratitude.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entry.gratitude
                .map((g) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPeach.withAlpha(18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '✨ $g',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.accentPeach.withAlpha(200),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],

        // Prompt used (subtle).
        if (entry.promptUsed.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '"${entry.promptUsed}"',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.textMuted.withAlpha(120),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  // ── Compact variant (Yesterday / Past 7 Days) ───────────────────

  Widget _buildCompact(ThemeData theme, String timeStr) {
    return Row(
      children: [
        // Mood icon.
        Text(entry.mood.icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),

        // Content snippet + time.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    timeStr,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontSize: 11),
                  ),
                  if (entry.gratitude.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '✨ ${entry.gratitude.length}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.accentPeach.withAlpha(180),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Delete.
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 16),
            color: AppTheme.textMuted.withAlpha(120),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
