import 'package:cloud_firestore/cloud_firestore.dart';

class FeedBackModal {
  String id;
  String userId;
  int vote;
  String feedBackText;
  Timestamp time;
  String? reply;
  FeedBackModal(
      {required this.id,
      required this.userId,
      required this.vote,
      required this.feedBackText,
      required this.time,
      this.reply});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'time': Timestamp.now(),
      'vote': vote,
      'feedBackText': feedBackText,
      'reply': reply,
    };
  }

  factory FeedBackModal.fromMap(Map<String, dynamic> map) {
    return FeedBackModal(
      id: map['id'] as String,
      userId: map['userId'] as String,
      time: map['time'] as Timestamp,
      vote: map['vote'] as int,
      feedBackText: map['feedBackText'] as String,
      reply: map['reply']?.toString(),
    );
  }
}
