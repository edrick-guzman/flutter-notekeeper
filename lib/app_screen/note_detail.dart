import "package:flutter/material.dart";
import 'package:flutter_notekeeper/app_screen/note_list.dart';
import 'package:flutter_notekeeper/utils/database_helper.dart';
import 'package:flutter_notekeeper/models/note.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class NoteDetail extends StatefulWidget {
  
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return _NoteDetailState(this.note, this.appBarTitle);
  }
}

class _NoteDetailState extends State<NoteDetail> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  static var _priorities = ['High', 'Low'];

  TextEditingController titleController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  

  String appBarTitle;
  Note note;

  // Constructor
  _NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    updateTitle();
    updateDescription();
    
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                },
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: ListView(
                children: <Widget>[
                  ListTile(
                      title: DropdownButton(
                    items: _priorities.map((String priority) {
                      return DropdownMenuItem<String>(
                          child: Text(priority), value: priority);
                    }).toList(),
                    value: getPriorityAsString(note.priority),
                    style: textStyle,
                    onChanged: (value) {
                      setState(() {
                        updatePriorityAsInt(value);
                      });
                    },
                  )),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                    child: TextField(
                      controller: titleController,
                      style: textStyle,
                      onChanged: (value) {
                        setState(() {
                          updateTitle();
                        });
                      },
                      decoration: InputDecoration(
                          labelStyle: textStyle,
                          labelText: 'Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                    child: TextField(
                      controller: descriptionController,
                      style: textStyle,
                      decoration: InputDecoration(
                          labelStyle: textStyle,
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )),
                      onChanged: (value) {
                        setState(() {
                          updateDescription();
                        });
                      },
                    ),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                      child: Row(children: <Widget>[
                        Expanded(
                            child: RaisedButton(
                          color: Colors.indigo,
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                            textScaleFactor: 1.2,
                          ),
                          onPressed: () {
                            _save();
                          },
                        )),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                          child: RaisedButton(
                            color: Colors.indigo,
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                              textScaleFactor: 1.2,
                            ),
                            onPressed: () {
                              _delete();
                            },
                          ),
                        )
                      ]))
                ],
              ),
            )
          )
        );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert String priority in the form of integer
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert integer from db to String
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = 'High';
        break;
      case 2:
        priority = 'Low';
        break;
    }

    return priority;
  }

  void updateTitle() {
    note.title = titleController.text;
    debugPrint('Title: ${note.title}');
  }
  
  void updateDescription() {
    note.description = descriptionController.text;
    debugPrint('Description: ${note.description}');
  }

  void _save() async {

    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id == null) {
      result = await databaseHelper.insertNote(note);
    } else {
      result = await databaseHelper.updateNote(note);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {

    moveToLastScreen();
    if (note.id == null) {
     _showAlertDialog('Status', 'No Note deleted');
    } 

    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error occured');
    }

  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message)
    );

    showDialog(
      context: context,
      builder: (_) => alertDialog
    );
  }

}
