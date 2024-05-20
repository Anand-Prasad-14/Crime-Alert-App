
import 'comment_model.dart';

class Post {
  String? postId, userId;
  String? firstName, avatar, title, content;
  DateTime? dateCreated;
  String? location;
  int? priority;
  List<String> media = [];
  int? countComment;
  List<Comment> comments = [];

  Post({
    this.postId,
    this.userId,
    this.firstName,
    this.avatar,
    this.title,
    this.content,
    this.priority,
    this.dateCreated,
    this.location,
    required this.media,
    this.countComment,
    required this.comments
  });
}