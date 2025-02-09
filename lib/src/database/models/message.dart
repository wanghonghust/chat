import 'package:chat/src/database/index.dart';
import 'package:sqflite/sqflite.dart';

class Message {
  final int? id;
  final int conversationId;
  final int role; // 0 for user, 1 for bot
  final String content;

  Message({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
  });

  Map<String, Object?> toMap() {
    return {
      'conversationId': conversationId,
      'role': role,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'Message{id: $id, conversationId: $conversationId, role: $role, content: $content}';
  }

  static Future<void> insertMessage(Message conversation) async {
    final db = await database;

    await db.insert(
      'messages',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Message>> getConversationMessage(int conversationId) async {
    // Get a reference to the database.
    final db = await database;

    final List<Map<String, Object?>> dogMaps = await db.query('messages',where: 'conversationId = ?', whereArgs: [conversationId]);

    return [
      for (final {
            'id': id as int,
            'conversationId': conversationId as int,
            'role': role as int,
            'content': content as String,
          } in dogMaps)
        Message(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content),
    ];
  }
}
