import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'Hike.dart';

class ReadScreen extends StatelessWidget{
  final Hike hike;

  ReadScreen({this.hike});

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(hike.title),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.fullscreen_exit), onPressed: (){
            Navigator.pop(context);
          },),
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: MarkdownBody(data: hike.story),
          ),
        ],
      ),
    );
  }
}