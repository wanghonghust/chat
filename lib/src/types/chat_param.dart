import 'package:chat/src/database/models/conversation.dart';

class ChatParam {
  final Conversation conversation;
  final String? model;
  final String? message;
  final bool isNew;
  ChatParam({
    required this.conversation,
    required this.isNew,
    this.message,
    this.model,
  });
}
