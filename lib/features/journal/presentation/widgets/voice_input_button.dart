import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:babyblue/core/theme/app_theme.dart';

/// Prominent mic button with live voice-to-text transcription.
///
/// Uses `speech_to_text` to capture speech and stream recognised
/// words into the provided [TextEditingController]. Shows a pulsing
/// animation while actively listening.
///
/// Falls back to a snackbar error if mic permission is denied.
class VoiceInputButton extends StatefulWidget {
  /// The text controller to append transcribed text into.
  final TextEditingController controller;

  /// Called with `true` when listening starts and `false` when it stops.
  final ValueChanged<bool>? onListeningChanged;

  const VoiceInputButton({
    super.key,
    required this.controller,
    this.onListeningChanged,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isInitialised = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    if (_isListening) _speech.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    // Initialise on first use.
    if (!_isInitialised) {
      _isInitialised = await _speech.initialize(
        onError: (error) {
          _stopListening();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Voice error: ${error.errorMsg}'),
                backgroundColor: AppTheme.errorRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
      );

      if (!_isInitialised && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Microphone permission denied. Please enable it in Settings.'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }
    }

    setState(() => _isListening = true);
    widget.onListeningChanged?.call(true);
    _pulseController.repeat(reverse: true);

    await _speech.listen(
      onResult: (result) {
        widget.controller.text = result.recognizedWords;
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length),
        );
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    _pulseController.stop();
    _pulseController.reset();
    if (mounted) {
      setState(() => _isListening = false);
      widget.onListeningChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: _toggleListening,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _isListening
                ? AppTheme.accentRose
                : AppTheme.primaryLavender,
            shape: BoxShape.circle,
            boxShadow: _isListening
                ? [
                    BoxShadow(
                      color: AppTheme.accentRose.withAlpha(60),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            _isListening ? Icons.stop_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
