import '../entities/reel_entity.dart';
import '../repositories/reel_repository.dart';

class GetReelsUseCase {
  final ReelRepository _repository;

  const GetReelsUseCase(this._repository);

  Future<List<ReelEntity>> call({dynamic lastDoc}) async {
    return await _repository.getReels(lastDoc: lastDoc);
  }
}
