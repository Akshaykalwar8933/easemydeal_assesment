import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reel_entity.dart';

// ReelModel is only in data layer - it knows about Firebase types
class ReelModel extends ReelEntity {
  const ReelModel({
    required super.id,
    required super.videoUrl,
    required super.thumbnailUrl,
    required super.username,
    required super.caption,
    required super.likes,
    required super.isLiked,
    required super.createdAt,
  });

  factory ReelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReelModel(
      id: doc.id,
      videoUrl: data['videoUrl'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      username: data['username'] as String? ?? '@unknown',
      caption: data['caption'] as String? ?? '',
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      isLiked: data['isLiked'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toFirestore() => {
    'videoUrl': videoUrl,
    'thumbnailUrl': thumbnailUrl,
    'username': username,
    'caption': caption,
    'likes': likes,
    'isLiked': isLiked,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
