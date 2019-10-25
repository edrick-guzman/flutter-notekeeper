import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_notekeeper/models/note.dart';

class DatabaseHelper {
  
  static DatabaseHelper _databaseHelper; 
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  // Singleton patern
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      return _databaseHelper = DatabaseHelper._createInstance();
    }
    
    return _databaseHelper;
  }

  /* Gets the database */
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async {
    //Get the directory path for both android and iOS to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // Open/create the database at a given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb); 
    return notesDatabase;
    
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // Fetch Operation
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    // var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert Operation
  Future<int> insertNote(Note note) async {
    debugPrint('Priority: ${note.priority}, Title: ${note.title}, Description: ${note.description}');
    Database db = await this.database;
    var result = await db.insert(noteTable ,note.toMap()); //.toMap() is SQLFlit plugin that deals with map opjects
    return result;
  }

  // Update Operation
  Future<int> updateNote(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(),where: '$colId = ?', whereArgs: [note.id]); //.toMap() is SQLFlit plugin that deals with map opjects
    return result;
  }

  // Delete Operation
  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id'); //.toMap() is SQLFlit plugin that deals with map opjects
    return result;
  }

  // Get number of note objects in Database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT(*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' (List<Map>) and convert it to 'Note List' (List<Note>)
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = new List<Note>();
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapOpject(noteMapList[i]));
    }

    return noteList;
  }
}