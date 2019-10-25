import "package:flutter/material.dart";

import 'app_screen/note_detail.dart';
import 'app_screen/note_list.dart';

void main() => runApp(Notekeeper());

class Notekeeper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notekeeper App",
      home: Notelist(),
      theme: ThemeData(
        primaryColor: Colors.indigo,
      ),
    );
  }
  
}