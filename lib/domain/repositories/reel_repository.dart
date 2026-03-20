import '../entities/reel_entity.dart';

abstract class ReelRepository {
  Future<List<ReelEntity>> getReels({dynamic lastDoc});
  Future<void> toggleLike(String reelId, bool isLiked);
}
