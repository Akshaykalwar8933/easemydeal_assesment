import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reel_controller.dart';
import '../widgets/reel_page_item.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late final PageController _pageController;
  late final ReelController _reelController;

  @override
  void initState() {
    super.initState();
    _reelController = Get.find<ReelController>();
    _pageController = PageController();

    // When video becomes ready, unlock scroll
    _reelController.canScrollNotifier.addListener(_onScrollLockChanged);
  }

  void _onScrollLockChanged() {
    // Nothing extra needed — the ValueListenableBuilder in build()
    // will rebuild and swap physics automatically
  }

  @override
  void dispose() {
    _reelController.canScrollNotifier.removeListener(_onScrollLockChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (_reelController.isLoading.value && _reelController.reels.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (_reelController.errorMessage.value.isNotEmpty &&
            _reelController.reels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: Colors.white54, size: 48),
                const SizedBox(height: 12),
                Text(
                  _reelController.errorMessage.value,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _reelController.fetchReels,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ValueListenableBuilder<bool>(
          valueListenable: _reelController.canScrollNotifier,
          builder: (context, canScroll, _) {
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              // KEY: swap physics based on video readiness
              physics: canScroll
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: _reelController.reels.length +
                  (_reelController.isLoadingMore.value ? 1 : 0),
              onPageChanged: _reelController.onPageChanged,
              itemBuilder: (context, index) {
                if (index == _reelController.reels.length) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                return ReelPageItem(index: index);
              },
            );
          },
        );
      }),
    );
  }
}