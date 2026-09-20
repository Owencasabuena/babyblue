import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:babyblue/core/theme/app_theme.dart';

/// A self-contained video player with custom overlay controls.
///
/// Features:
/// - Play / Pause toggle
/// - Skip backward 10 s / forward 10 s
/// - Progress scrubber with current and total duration
/// - Loading spinner while buffering
/// - Tap-to-toggle overlay visibility
class VideoPlayerWidget extends StatefulWidget {
  /// Direct URL to the `.mp4` video source.
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialised = false;
  bool _showControls = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    _controller.addListener(_onPlayerUpdate);

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() => _isInitialised = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _onPlayerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerUpdate);
    _controller.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────

  void _togglePlayPause() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }

  void _skipBackward() {
    final current = _controller.value.position;
    _controller.seekTo(current - const Duration(seconds: 10));
  }

  void _skipForward() {
    final current = _controller.value.position;
    final max = _controller.value.duration;
    final target = current + const Duration(seconds: 10);
    _controller.seekTo(target > max ? max : target);
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Error state.
    if (_hasError) {
      return _buildPlaceholder(
        icon: Icons.error_outline_rounded,
        label: 'Unable to load video',
      );
    }

    // Loading state.
    if (!_isInitialised) {
      return _buildPlaceholder(
        icon: Icons.play_circle_outline_rounded,
        label: 'Loading…',
        showSpinner: true,
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Video ──────────────────────────────────────────────
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),

          // ── Overlay controls ──────────────────────────────────
          if (_showControls) ...[
            // Dim overlay.
            Positioned.fill(
              child: Container(color: Colors.black.withAlpha(90)),
            ),

            // Centre row: skip-back, play/pause, skip-forward.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: Icons.replay_10_rounded,
                  onPressed: _skipBackward,
                ),
                const SizedBox(width: 28),
                _ControlButton(
                  icon: _controller.value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  size: 56,
                  onPressed: _togglePlayPause,
                ),
                const SizedBox(width: 28),
                _ControlButton(
                  icon: Icons.forward_10_rounded,
                  onPressed: _skipForward,
                ),
              ],
            ),

            // Bottom: progress bar + timestamps.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ProgressBar(controller: _controller),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String label,
    bool showSpinner = false,
  }) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: AppTheme.textDark,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSpinner)
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white70,
                  ),
                )
              else
                Icon(icon, color: Colors.white70, size: 44),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private Widgets ────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: size),
      onPressed: onPressed,
      splashRadius: size * 0.6,
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final VideoPlayerController controller;

  const _ProgressBar({required this.controller});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final position = controller.value.position;
    final duration = controller.value.duration;
    final progressMs = position.inMilliseconds.toDouble();
    final totalMs = duration.inMilliseconds.toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withAlpha(140),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Text(_fmt(position),
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: AppTheme.accentPeach,
                inactiveTrackColor: Colors.white30,
                thumbColor: AppTheme.accentPeach,
                overlayColor: AppTheme.accentPeach.withAlpha(40),
              ),
              child: Slider(
                min: 0,
                max: totalMs > 0 ? totalMs : 1,
                value: progressMs.clamp(0, totalMs > 0 ? totalMs : 1),
                onChanged: (value) {
                  controller.seekTo(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(_fmt(duration),
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
