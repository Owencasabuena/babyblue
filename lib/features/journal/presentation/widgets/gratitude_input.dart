import 'package:flutter/material.dart';

import 'package:babyblue/core/theme/app_theme.dart';

/// Toggleable gratitude section for the journal quick-capture zone.
///
/// Shows a "✨ Add Gratitude" pill that reveals up to 3 mini text fields.
/// Each filled field becomes a coloured pill tag in the summary view.
class GratitudeInput extends StatefulWidget {
  /// Called whenever the gratitude list changes.
  final ValueChanged<List<String>> onChanged;

  /// Initial gratitude items (for editing).
  final List<String> initial;

  const GratitudeInput({
    super.key,
    required this.onChanged,
    this.initial = const [],
  });

  @override
  State<GratitudeInput> createState() => _GratitudeInputState();
}

class _GratitudeInputState extends State<GratitudeInput>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final List<TextEditingController> _controllers;

  static const _placeholders = [
    'A warm drink ☕',
    '10 min of quiet 🤫',
    'A smile from baby 👶',
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final initial =
          i < widget.initial.length ? widget.initial[i] : '';
      return TextEditingController(text: initial);
    });

    // If there are initial values, start expanded.
    if (widget.initial.isNotEmpty) _expanded = true;

    for (final c in _controllers) {
      c.addListener(_emitChange);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_emitChange);
      c.dispose();
    }
    super.dispose();
  }

  void _emitChange() {
    final values = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    widget.onChanged(values);
  }

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return GestureDetector(
        onTap: () => setState(() => _expanded = true),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.accentPeach.withAlpha(18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentPeach.withAlpha(50),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('✨', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Add Gratitude',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentPeach,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.accentPeach.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accentPeach.withAlpha(40),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '3 things I\'m grateful for',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentPeach.withAlpha(220),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    for (final c in _controllers) {
                      c.clear();
                    }
                    setState(() => _expanded = false);
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppTheme.textMuted.withAlpha(120),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _controllers[i],
                  maxLength: 50,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _placeholders[i],
                    counterText: '',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: AppTheme.cardWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.accentPeach.withAlpha(40),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.accentPeach.withAlpha(40),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.accentPeach,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
