import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/reel_entity.dart';
import '../../domain/repositories/reel_repository.dart';
import '../../domain/usecases/get_reels_usecase.dart';
import 'package:video_player/video_player.dart';

class ReelController extends GetxController {
  final GetReelsUseCase _getReelsUseCase;
  final CacheManager _cacheManager;

  ReelController(this._getReelsUseCase, this._cacheManager);

  final RxList<ReelEntity> reels = <ReelEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxString errorMessage = ''.obs;

  // Scroll lock — false until current video is initialized
  final ValueNotifier<bool> canScrollNotifier = ValueNotifier(false);

  final Map<int, String> videoErrors = {};
  final Map<int, VideoPlayerController> _videoControllers = {};
  bool _hasMore = true;
  dynamic _lastDoc;

  @override
  void onInit() {
    super.onInit();
    fetchReels();
  }

  @override
  void onClose() {
    for (final vc in _videoControllers.values) {
      vc.dispose();
    }
    canScrollNotifier.dispose();
    super.onClose();
  }

  // ─── Public getter ────────────────────────────────────────────────────────

  VideoPlayerController? getControllerAt(int index) =>
      _videoControllers[index];

  // ─── Fetch ────────────────────────────────────────────────────────────────

  Future<void> fetchReels() async {
    isLoading.value = true;
    errorMessage.value = '';
    canScrollNotifier.value = false;
    try {
      final result = await _getReelsUseCase(lastDoc: null);
      reels.assignAll(result);
      _hasMore = result.length >= AppConstants.pageLimit;
      if (result.isNotEmpty) {
        await _initPlayerAt(0);     // wait for first video
        _preloadAhead(0);           // then preload next ones
      }
    } catch (e) {
      errorMessage.value = 'Failed to load reels: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreReels() async {
    if (!_hasMore || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final result = await _getReelsUseCase(lastDoc: _lastDoc);
      reels.addAll(result);
      _hasMore = result.length >= AppConstants.pageLimit;
    } catch (e) {
      errorMessage.value = 'Failed to load more: ${e.toString()}';
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ─── Page change ──────────────────────────────────────────────────────────

  Future<void> onPageChanged(int index) async {
    final previous = currentIndex.value;

    // 1. Lock scroll immediately
    canScrollNotifier.value = false;

    // 2. Pause & mute previous — stops audio bleed
    final prevVc = _videoControllers[previous];
    if (prevVc != null) {
      await prevVc.pause();
      await prevVc.setVolume(0); // silence it fully
    }

    // 3. Update index
    currentIndex.value = index;

    // 4. Init + play current (awaited so scroll unlocks only when ready)
    await _initPlayerAt(index);

    // 5. Re-mute previous (safety — sometimes setVolume races)
    prevVc?.setVolume(0);

    // 6. Preload ahead and clean up old
    _preloadAhead(index);
    _disposeFarAway(index);

    // 7. Fetch more when near end
    if (index >= reels.length - 3) fetchMoreReels();
  }

  // ─── Like ─────────────────────────────────────────────────────────────────

  Future<void> toggleLike(int index) async {
    final reel = reels[index];
    final newLiked = !reel.isLiked;
    final newLikes = newLiked ? reel.likes + 1 : reel.likes - 1;
    reels[index] = reel.copyWith(isLiked: newLiked, likes: newLikes);
    try {
      await Get.find<ReelRepository>().toggleLike(reel.id, newLiked);
    } catch (_) {
      reels[index] = reel; // revert
    }
  }

  // ─── Video init ───────────────────────────────────────────────────────────

  Future<void> _initPlayerAt(int index) async {
    if (index < 0 || index >= reels.length) return;

    // Clear any previous error for this index
    videoErrors.remove(index);
    update(['video_$index']);

    final existing = _videoControllers[index];
    if (existing != null && existing.value.isInitialized) {
      await existing.setVolume(1.0);
      await existing.play();
      _unlockScroll(index);
      update(['video_$index']);
      return;
    }

    final url = reels[index].videoUrl;
    if (url.isEmpty) {
      videoErrors[index] = 'No video URL found.';
      _unlockScroll(index); // unlock so user can scroll past
      update(['video_$index']);
      return;
    }

    try {
      VideoPlayerController vc;

      final cached = await _cacheManager.getFileFromCache(url);
      if (cached != null) {
        vc = VideoPlayerController.file(cached.file);
      } else {
        vc = VideoPlayerController.networkUrl(Uri.parse(url));
        _cacheManager.downloadFile(url);
      }

      await vc.initialize();
      vc.setLooping(true);

      if (index == currentIndex.value) {
        await vc.play();
        await vc.setVolume(1.0);
      } else {
        await vc.setVolume(0);
        await vc.pause();
      }

      _videoControllers[index] = vc;
      _unlockScroll(index);
      update(['video_$index']);

    } catch (e) {
      debugPrint('Video error at $index: $e');

      // Parse a clean message from the exception
      String message = 'Video could not be loaded.';
      final errStr = e.toString().toLowerCase();

      if (errStr.contains('403'))       message = 'Access denied (403).';
      else if (errStr.contains('404'))  message = 'Video not found (404).';
      else if (errStr.contains('500'))  message = 'Server error (500).';
      else if (errStr.contains('socketexception') ||
          errStr.contains('failed host lookup')) {
        message = 'No internet connection.';
      }

      videoErrors[index] = message;
      _unlockScroll(index); // IMPORTANT — unlock so user isn't stuck
      update(['video_$index']);
    }
  }

  void _unlockScroll(int index) {
    // Only unlock if this is the current page
    if (index == currentIndex.value) {
      canScrollNotifier.value = true;
    }
  }

  // ─── Preload ──────────────────────────────────────────────────────────────

  void _preloadAhead(int current) {
    for (int i = current + 1;
    i <= current + AppConstants.preloadCount && i < reels.length;
    i++) {
      if (!_videoControllers.containsKey(i)) {
        _initPlayerAt(i); // fire and forget — paused + muted
      }
    }
  }


  // -------retry logic for video initialization failure (e.g., network issues)-------
  Future<void> retryVideo(int index) async {
    // Dispose broken controller if any
    _videoControllers[index]?.dispose();
    _videoControllers.remove(index);
    // Re-init from scratch
    await _initPlayerAt(index);
  }

  // ─── Dispose far away ─────────────────────────────────────────────────────

  void _disposeFarAway(int current) {
    final keys = _videoControllers.keys.where((k) =>
    k < current - 2 ||
        k > current + AppConstants.preloadCount + 1).toList();

    for (final k in keys) {
      _videoControllers[k]?.dispose();
      _videoControllers.remove(k);
    }
  }
}