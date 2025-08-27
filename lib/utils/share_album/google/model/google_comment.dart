import 'google_user.dart';

class GoogleComment {
  final CommentType type;
  final String? comment;
  final int createdTime;
  final GoogleUser user;

  GoogleComment({
    required this.type,
    this.comment,
    required this.createdTime,
    required this.user,
  });

  @override
  String toString() {
    return 'GoogleComment{type: $type, comment: $comment, createdTime: $createdTime, user: $user}';
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'comment': comment,
      'createdTime': createdTime,
      'user': user.toJson(),
    };
  }

  factory GoogleComment.fromJson(Map<String, dynamic> json) {
    return GoogleComment(
      type: CommentType.values.firstWhere((e) => e.toString() == json['type']),
      comment: json['comment'],
      createdTime: json['createdTime'],
      user: GoogleUser.fromJson(json['user']),
    );
  }
}

enum CommentType { COMMENT, FAVORITE }
