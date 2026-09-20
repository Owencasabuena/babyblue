import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/mood_tracker/presentation/providers/mood_provider.dart';
import 'package:babyblue/features/mood_tracker/presentation/widgets/emoji_picker.dart';

/// A modal bottom sheet for logging today's mood.
///
/// Contains the existing [EmojiPicker], an optional note text field,
/// and a save button. Auto-dismisses on successful save.
class MoodLogSheet extends StatefulWidget {
  const MoodLogSheet._();

  /// Present the mood logging sheet.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MoodLogSheet._(),
    );
  }

  @override
  State<MoodLogSheet> createState() => _MoodLogSheetState();
}

class _MoodLogSheetState extends State<MoodLogSheet> {
  int? _selectedScore;
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Adjust for keyboard.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ──────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // ── Title ────────────────────────────────────────
              Text(
                'How are you feeling?',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Tap an emoji to log your mood',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // ── Emoji picker ─────────────────────────────────
              EmojiPicker(
                selectedScore: _selectedScore,
                onSelect: (score) => setState(() => _selectedScore = score),
              ),
              const SizedBox(height: 24),

              // ── Note field ───────────────────────────────────
              TextField(
                controller: _noteController,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)…',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Icon(Icons.edit_note_rounded,
                        color: AppTheme.textMuted),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppTheme.primaryLight.withAlpha(51),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppTheme.primaryLight.withAlpha(51),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Save button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _selectedScore != null ? 1.0 : 0.5,
                  child: Consumer(
                    builder: (context, ref, _) {
                      return ElevatedButton.icon(
                        onPressed:
                            (_selectedScore != null && !_isSaving)
                                ? () => _saveMood(ref)
                                : null,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.favorite_rounded, size: 20),
                        label:
                            Text(_isSaving ? 'Saving…' : 'Save Mood'),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMood(WidgetRef ref) async {
    if (_selectedScore == null) return;

    setState(() => _isSaving = true);

    await ref.read(moodEntriesProvider.notifier).logMood(
          moodScore: _selectedScore!,
          note: _noteController.text.trim(),
        );

    if (mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mood saved ✨'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
