class ReelEntity {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String username;
  final String caption;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;

  const ReelEntity({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.username,
    required this.caption,
    required this.likes,
    required this.isLiked,
    required this.createdAt,
  });

  // Value equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ReelEntity && id == other.id);

  @override
  int get hashCode => id.hashCode;

  ReelEntity copyWith({
    String? id, String? videoUrl, String? thumbnailUrl,
    String? username, String? caption, int? likes,
    bool? isLiked, DateTime? createdAt,
  }) => ReelEntity(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      username: username ?? this.username,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
    isLiked: isLiked ?? this.isLiked,
    createdAt: createdAt ?? this.createdAt,
  );
}
