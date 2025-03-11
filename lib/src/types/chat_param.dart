import 'package:chat/src/database/models/conversation.dart';

class ChatParam {
  final Conversation conversation;
  final bool isNew;
  ChatParam({required this.conversation, required this.isNew});
}
