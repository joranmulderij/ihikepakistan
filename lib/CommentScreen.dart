import 'package:flutter/material.dart';
import 'package:ihikepakistan/main.dart';
import 'package:http/http.dart' as http;

import 'Hike.dart';

class CommentScreen extends StatefulWidget {
  final Hike hike;
  CommentScreen({this.hike});
  CommentState createState() => CommentState(
        hike: hike,
      );
}

class CommentState extends State<CommentScreen> {
  double sendIconOffset = 0;
  Color sendIconColor = Colors.white;
  IconData sendIconData = Icons.send;
  TextEditingController authorController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  Hike hike;
  String authorError;
  String commentError;

  CommentState({this.hike});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Comment'),
      ),
      body: Center(
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Theme(
                data: ThemeData(
                  primaryColor: Colors.amber,
                ),
                child: TextField(
                  controller: authorController,
                  maxLength: 20,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.account_circle,
                      color: (authorError == null) ? null : Colors.red,
                    ),
                    filled: false,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    hintText: 'Your Name',
                    errorText: authorError,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            ListTile(
              title: Theme(
                data: ThemeData(
                  primaryColor: Colors.amber,
                ),
                child: TextField(
                  onChanged: (String value) {
                    if (value.isEmpty) {
                      setState(() {
                        commentError = 'empty';
                      });
                    } else {
                      setState(() {
                        commentError = null;
                      });
                    }
                  },
                  controller: commentController,
                  keyboardType: TextInputType.multiline,
                  maxLength: 100,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.comment,
                      color:
                          (commentError == null) ? null : Colors.red.shade700,
                    ),
                    filled: false,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    hintText: 'Write a Comment\n\n(optional)',
                    errorText: commentError,
                  ),
                  maxLines: 100,
                  minLines: 3,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          child: AnimatedContainer(
            child: Icon(
              sendIconData,
              color: sendIconColor,
            ),
            padding: EdgeInsets.fromLTRB(sendIconOffset, 0, 0, 0),
            duration: Duration(
              milliseconds: 500,
            ),
            curve: Curves.easeIn,
          ),
          onPressed: () {
            setState(() {
              sendIconOffset = 100;
            });
            String author = authorController.text;
            String comment = commentController.text;
            String toSend = author + '@' + comment.trim().split('\n').join('@');
            http
                .get(
                    'https://script.google.com/macros/s/AKfycbx3CajrS-U7X0wx8WMQNf2rUHJnITA7DDfz0V6pOEkn2hq6MEZj/exec?action=send&comment=$toSend&hike=${hike.id}')
                .then((value) => returnIcon(context, value))
                .catchError((e) {
              print('errr');
            });
          },
        );
      }),
    );
  }

  void returnIcon(BuildContext context, http.Response res) {
    setState(() {
      sendIconColor = Colors.black;
      sendIconOffset = 0;
      sendIconData = Icons.check_box;
    });
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.amber,
      content: Text(
        'Comment Send. Thanks for writing a Comment!',
        style: TextStyle(color: Colors.black),
      ),
    ));
    prefs.setBool('did${hike.id}comment', true);
  }
}
