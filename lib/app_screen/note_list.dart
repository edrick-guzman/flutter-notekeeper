import "package:flutter/material.dart";
import 'package:flutter_notekeeper/app_screen/note_detail.dart';
import 'package:flutter_notekeeper/utils/database_helper.dart';
import 'package:flutter_notekeeper/models/note.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

void main() => runApp(Notelist());

class Notelist extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotelistState();
  }
  
}

class _NotelistState extends State<Notelist> {
  DatabaseHelper databaseHelper = new DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    // TODO: implement build
    return Scaffold(
      appBar: AppBar (title: Text("Notes"), centerTitle: false,),
      body: getNoteListView(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add more',
        onPressed: () {
          navigateToDetail(Note('','',2), 'Add Note');
        },
      ),
    );
  }
  ListView getNoteListView(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority)
            ),
            title: Text(this.noteList[position].title , style: titleStyle),
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.grey),
              onTap: () {
                _delete(context, noteList[position]);
              },
            ),
            onTap: () {
              navigateToDetail(this.noteList[position], 'Edit Note');
            },
          )
        );
      },

    );
  }

  // Returns priority icon
  Color getPriorityColor(int priority) {
    switch(priority) {
      case 1:
        return Colors.red;
        break;
      case 2: 
        return Colors.yellow;
        break;
      default: 
        return Colors.white;
        break;
    }
  }

  // Returns priority icon
  Icon getPriorityIcon(int priority) {
    switch(priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2: 
        return Icon(Icons.keyboard_arrow_right);
        break;
      default: 
        return Icon(Icons.help);
        break;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
    }
    updateListView();
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}


