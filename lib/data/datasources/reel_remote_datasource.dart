import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/reel_model.dart';

// Interface (Dependency Inversion Principle)
abstract class ReelRemoteDataSource {
  Future<List<ReelModel>> getReels({DocumentSnapshot? lastDoc});
  Future<void> toggleLike(String reelId, bool isLiked);
}

// Implementation
class ReelRemoteDataSourceImpl implements ReelRemoteDataSource {
  final FirebaseFirestore _firestore;

  const ReelRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<ReelModel>> getReels({DocumentSnapshot? lastDoc}) async {
    try {
      Query query = _firestore
          .collection(AppConstants.reelsCollection)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.pageLimit);

      // Pagination cursor
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => ReelModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error');
    }
  }

  @override
  Future<void> toggleLike(String reelId, bool isLiked) async {
    await _firestore
        .collection(AppConstants.reelsCollection)
        .doc(reelId)
        .update({
      'isLiked': isLiked,
      'likes': FieldValue.increment(isLiked ? 1 : -1),
    });
  }
}

