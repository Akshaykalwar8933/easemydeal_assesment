import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/reel_controller.dart';

class ReelVideoPlayer extends StatefulWidget {
  final int index;
  const ReelVideoPlayer({super.key, required this.index});

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  ReelController get _rc => Get.find<ReelController>();
  VideoPlayerController? _vc;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  void _attachController() {
    final vc = _rc.getControllerAt(widget.index);
    if (vc != null && _vc != vc) {
      _vc?.removeListener(_onVideoUpdate);
      _vc = vc;
      _vc!.addListener(_onVideoUpdate);
    }
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vc?.removeListener(_onVideoUpdate);
    super.dispose();
  }

  void _handleTap() {
    final vc = _rc.getControllerAt(widget.index);
    if (vc == null || !vc.value.isInitialized) return;
    vc.value.isPlaying ? vc.pause() : vc.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReelController>(
      id: 'video_${widget.index}',
      builder: (_) {
        _attachController();

        // ── Error state ──────────────────────────────────────────────────
        final error = _rc.videoErrors[widget.index];
        if (error != null) {
          return _buildErrorScreen(error);
        }

        final vc = _rc.getControllerAt(widget.index);
        final reel = _rc.reels[widget.index];

        // ── Loading state ────────────────────────────────────────────────
        if (vc == null || !vc.value.isInitialized) {
          return _buildThumbnail(reel.thumbnailUrl);
        }

        // ── Video ready ──────────────────────────────────────────────────
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: vc.value.size.width,
                  height: vc.value.size.height,
                  child: VideoPlayer(vc),
                ),
              ),
              if (!vc.value.isPlaying)
                const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Error UI ─────────────────────────────────────────────────────────────

  Widget _buildErrorScreen(String message) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Broken video icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                color: Colors.white38,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Video unavailable',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            // Retry button
            GestureDetector(
              onTap: () {
                // Clear error and re-init
                _rc.videoErrors.remove(widget.index);
                _rc.update(['video_${widget.index}']);
                _rc.retryVideo(widget.index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Tap to retry',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Thumbnail + spinner ──────────────────────────────────────────────────

  Widget _buildThumbnail(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (url.isNotEmpty && url.startsWith('http'))
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
            const ColoredBox(color: Colors.black),
          )
        else
          const ColoredBox(color: Colors.black),
        const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      ],
    );
  }
}