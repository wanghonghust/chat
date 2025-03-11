import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> initDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'data.db');
  Database db = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
      'CREATE TABLE conversations(id INTEGER PRIMARY KEY, title TEXT)',
    );
    await db.execute(
        'CREATE TABLE messages(id INTEGER PRIMARY KEY, conversationId INTEGER, role INTEGER, model TEXT, content TEXT, thinkContent TEXT, FOREIGN KEY(conversationId) REFERENCES conversations(id))');
  });
  return db;
}

final database = initDatabase();
