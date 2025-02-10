import 'package:chat/src/database/models/conversation.dart';
import 'package:flutter/material.dart';

class AppDataProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  AppDataProvider(this._conversations);
  List<Conversation>? get conversations => _conversations;
  void addConversation(Conversation conversation) {
    _conversations.add(conversation);
    notifyListeners();
  }

  void setConversations(List<Conversation> lconversations) {
    _conversations = lconversations;
    notifyListeners();
  }
}
