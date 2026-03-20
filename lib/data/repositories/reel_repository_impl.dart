import '../../domain/entities/reel_entity.dart';
import '../../domain/repositories/reel_repository.dart';
import '../datasources/reel_remote_datasource.dart';

class ReelRepositoryImpl implements ReelRepository {
  final ReelRemoteDataSource _dataSource;

  const ReelRepositoryImpl(this._dataSource);

  @override
  Future<List<ReelEntity>> getReels({dynamic lastDoc}) async {
    return await _dataSource.getReels(lastDoc: lastDoc);
  }

  @override
  Future<void> toggleLike(String reelId, bool isLiked) async {
    return await _dataSource.toggleLike(reelId, isLiked);
  }
}
