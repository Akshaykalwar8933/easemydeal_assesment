import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/reel_entity.dart';
import '../controllers/reel_controller.dart';


class ReelOverlay extends StatelessWidget {
  final int index;
  final ReelEntity reel;

  const ReelOverlay({super.key, required this.index, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Gradient at bottom
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
      ),

      // Right side actions
      Positioned(
        right: 12,
        bottom: 100,
        child: Column(
          children: [
            // Like Button
            Obx(() {
              final r = Get.find<ReelController>().reels[index];
              return _ActionButton(
                icon: r.isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatLikes(r.likes),
                color: r.isLiked ? Colors.red : Colors.white,
                onTap: () => Get.find<ReelController>().toggleLike(index),
              );
            }),
            const SizedBox(height: 20),
            _ActionButton(icon: Icons.comment, label: 'Comment', onTap: () {}),
            const SizedBox(height: 20),
            _ActionButton(icon: Icons.share, label: 'Share', onTap: () {}),
          ],
        ),
      ),

      // Bottom info
      Positioned(
        bottom: 80,
        left: 16,
        right: 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reel.username,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(reel.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    ]);
  }

  String _formatLikes(int likes) {
    if (likes >= 1000000) return '${(likes / 1000000).toStringAsFixed(1)}M';
    if (likes >= 1000) return '${(likes / 1000).toStringAsFixed(1)}K';
    return '$likes';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon, required this.label,
    required this.onTap, this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ]),
    );
  }
}
