import 'package:chat/src/database/models/conversation.dart';
import 'package:flutter/material.dart';

class AppDataProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  String _currentRoute;
  GlobalKey<NavigatorState> _navigatorKey;

  AppDataProvider(this._conversations, this._currentRoute, this._navigatorKey);
  String get currentRoute => _currentRoute;
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  void setCurrentRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }

  List<Conversation> get conversations => _conversations;
  void addConversation(Conversation conversation) {
    _conversations.add(conversation);
    notifyListeners();
  }

  void setConversations(List<Conversation> lconversations) {
    _conversations = lconversations;
    notifyListeners();
  }
}
