import 'package:easemydeal_assesment/presentation/widgets/reel_overlay.dart';
import 'package:easemydeal_assesment/presentation/widgets/reel_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/reel_controller.dart';

class ReelPageItem extends StatelessWidget {
  final int index;

  const ReelPageItem({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReelController>();

    return Obx(() {
      // Guard: if reels not loaded yet
      if (index >= controller.reels.length) {
        return const SizedBox.shrink();
      }

      final reel = controller.reels[index];

      return Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Video
          ReelVideoPlayer(index: index),

          // Layer 2: UI Overlay
          ReelOverlay(index: index, reel: reel),
        ],
      );
    });
  }
}