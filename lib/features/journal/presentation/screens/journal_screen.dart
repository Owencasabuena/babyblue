import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/journal/data/journal_prompts.dart';
import 'package:babyblue/features/journal/data/models/journal_entry.dart';
import 'package:babyblue/features/journal/data/models/journal_mood.dart';
import 'package:babyblue/features/journal/presentation/providers/journal_provider.dart';
import 'package:babyblue/features/journal/presentation/widgets/gratitude_input.dart';
import 'package:babyblue/features/journal/presentation/widgets/journal_entry_card.dart';
import 'package:babyblue/features/journal/presentation/widgets/mood_selector.dart';
import 'package:babyblue/features/journal/presentation/widgets/voice_input_button.dart';

/// The journal screen — low-friction, voice-first capture with a
/// segmented timeline feed (Today / Yesterday / Past 7 Days).
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _contentController = TextEditingController();
  JournalMood? _selectedMood;
  String _currentPrompt = JournalPrompts.defaultPrompt;
  List<String> _gratitudeItems = [];
  bool _isVoiceInput = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _onMoodSelected(JournalMood mood) {
    setState(() {
      _selectedMood = mood;
      _currentPrompt = JournalPrompts.forMood(mood);
    });
  }

  Future<void> _saveEntry() async {
    final content = _contentController.text.trim();
    if (content.isEmpty || _selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedMood == null
                ? 'Pick a mood first 💜'
                : 'Write or speak a thought first ✨',
          ),
          backgroundColor: AppTheme.primaryLavender,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    await ref.read(journalEntriesProvider.notifier).addEntry(
          mood: _selectedMood!,
          content: content,
          promptUsed: _currentPrompt,
          gratitude: _gratitudeItems,
          inputType: _isVoiceInput ? 'voice' : 'text',
        );

    // Reset the form.
    _contentController.clear();
    setState(() {
      _selectedMood = null;
      _currentPrompt = JournalPrompts.defaultPrompt;
      _gratitudeItems = [];
      _isVoiceInput = false;
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entry saved 💜'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayAsync = ref.watch(todayEntriesProvider);
    final yesterdayAsync = ref.watch(yesterdayEntriesProvider);
    final pastWeekAsync = ref.watch(pastWeekEntriesProvider);

    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Header ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Text('My Journal',
                      style: theme.textTheme.headlineLarge),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    'A gentle space for your thoughts.',
                    style:
                        theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ),
              ),

              // ── Quick Capture Zone ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: _QuickCaptureCard(
                    contentController: _contentController,
                    selectedMood: _selectedMood,
                    currentPrompt: _currentPrompt,
                    isSaving: _isSaving,
                    onMoodSelected: _onMoodSelected,
                    onGratitudeChanged: (items) =>
                        _gratitudeItems = items,
                    onVoiceListeningChanged: (listening) =>
                        setState(() => _isVoiceInput = listening || _isVoiceInput),
                    onSave: _saveEntry,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Today Section ────────────────────────────────
              _buildSection(
                theme: theme,
                title: 'Today',
                icon: Icons.today_rounded,
                asyncEntries: todayAsync,
                compact: false,
              ),

              // ── Yesterday Section ────────────────────────────
              _buildSection(
                theme: theme,
                title: 'Yesterday',
                icon: Icons.history_rounded,
                asyncEntries: yesterdayAsync,
                compact: true,
              ),

              // ── Past 7 Days Section ──────────────────────────
              _buildSection(
                theme: theme,
                title: 'Past 7 Days',
                icon: Icons.date_range_rounded,
                asyncEntries: pastWeekAsync,
                compact: true,
                showDate: true,
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required AsyncValue<List<JournalEntry>> asyncEntries,
    required bool compact,
    bool showDate = false,
  }) {
    return SliverToBoxAdapter(
      child: asyncEntries.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (entries) {
          if (entries.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header.
                Row(
                  children: [
                    Icon(icon, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Entry cards.
                ...entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              DateFormat('EEEE, MMM d')
                                  .format(entry.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        JournalEntryCard(
                          entry: entry,
                          compact: compact,
                          onEdit: compact
                              ? null
                              : () => _editEntry(entry),
                          onDelete: () => _deleteEntry(entry.id),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  void _editEntry(JournalEntry entry) {
    // Populate the capture zone with the existing entry for editing.
    _contentController.text = entry.content;
    setState(() {
      _selectedMood = entry.mood;
      _currentPrompt = entry.promptUsed;
      _gratitudeItems = List.from(entry.gratitude);
    });

    // Delete the old entry so saving creates a fresh one.
    ref.read(journalEntriesProvider.notifier).deleteEntry(entry.id);
  }

  void _deleteEntry(String id) {
    ref.read(journalEntriesProvider.notifier).deleteEntry(id);
  }
}

// ── Quick Capture Card ────────────────────────────────────────────

class _QuickCaptureCard extends StatelessWidget {
  final TextEditingController contentController;
  final JournalMood? selectedMood;
  final String currentPrompt;
  final bool isSaving;
  final ValueChanged<JournalMood> onMoodSelected;
  final ValueChanged<List<String>> onGratitudeChanged;
  final ValueChanged<bool> onVoiceListeningChanged;
  final VoidCallback onSave;

  const _QuickCaptureCard({
    required this.contentController,
    required this.selectedMood,
    required this.currentPrompt,
    required this.isSaving,
    required this.onMoodSelected,
    required this.onGratitudeChanged,
    required this.onVoiceListeningChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryLight.withAlpha(55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLavender.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card title.
          Text(
            'New Entry',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Mood selector.
          MoodSelector(
            selected: selectedMood,
            onMoodSelected: onMoodSelected,
          ),
          const SizedBox(height: 14),

          // Prompt pill.
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('💭', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentPrompt,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.primaryLavender,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Text input.
          TextField(
            controller: contentController,
            maxLines: 3,
            maxLength: 280,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Tap mic to speak or type a thought...',
              counterText: '',
              filled: true,
              fillColor: AppTheme.surfaceWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppTheme.primaryLight.withAlpha(60),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppTheme.primaryLight.withAlpha(60),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppTheme.primaryLavender,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '1–3 sentences · keep it gentle',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: AppTheme.textMuted.withAlpha(140),
            ),
          ),
          const SizedBox(height: 14),

          // Gratitude input.
          GratitudeInput(onChanged: onGratitudeChanged),
          const SizedBox(height: 14),

          // Action row: mic + save.
          Row(
            children: [
              VoiceInputButton(
                controller: contentController,
                onListeningChanged: onVoiceListeningChanged,
              ),
              const Spacer(),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                  label: Text(isSaving ? 'Saving…' : 'Save Entry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLavender,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
