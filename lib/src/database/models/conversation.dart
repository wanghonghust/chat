import 'package:chat/src/database/index.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Conversation {
  final int? id;
  final String title;

  Conversation({
    this.id,
    required this.title,
  });

  Map<String, Object?> toMap() {
    return {
      'title': title,
    };
  }

  @override
  String toString() {
    return 'Conversation{id: $id, title: $title}';
  }

  static Future<int> insertConversation(Conversation conversation) async {
    final db = await database;

    return db.insert(
      'conversations',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Conversation>> getConversations() async {
    // Get a reference to the database.
    final db = await database;

    final List<Map<String, Object?>> conversationMaps =
        await db.query('conversations');

    return [
      for (final {
            'id': id as int,
            'title': title as String,
          } in conversationMaps)
        Conversation(id: id, title: title),
    ];
  }

  static Future<void> deleteConversation(int id) async {
    final db = await database;
    await db.delete('messages',
        where: 'conversationId = ?', whereArgs: [id]).then((res) async {
      print('Deleted $res messages');
      await db.delete('conversations', where: 'id = ?', whereArgs: [id]).then(
          (res1) {
        print('Deleted $res1 conversation');
      });
    });
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Conversation) return false;
    return id == other.id;
  }
}
