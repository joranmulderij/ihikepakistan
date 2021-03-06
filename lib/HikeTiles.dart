import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Hike.dart';
import 'InfoScreen.dart';

/*class HikeTile extends StatelessWidget{
  final Hike hike;
  final rating;

  HikeTile({this.hike, this.rating});

  Widget build(BuildContext context){
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation){
        if(orientation == Orientation.portrait){
          return HikeTileVert(rating: rating, hike: hike,);
        }
        else{
          return HikeTileHor(rating: rating, hike: hike,);
        }
      },
    );
  }
}*/

class HikeTile extends StatelessWidget {
  final Hike hike;

  HikeTile({this.hike});

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
      height: 180,
      width: 400,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InfoScreen(
                hike: hike,
              ),
            ),
          );
        },
        child: Hero(
          tag: hike.title + 'tag',
          child: Card(
            elevation: 5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: Image.memory(
                    base64Decode(hike.photo.replaceFirst('data:image/png;base64,', '')),
                    fit: BoxFit.cover,
                    height: 180,
                    width: 200,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: ListTile(
                          title: Text(hike.title),
                          subtitle: Text(hike.difficulty),
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Column(
                              children: [
                                Text(
                                  'Length',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  hike.length,
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  'Km',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 8),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Climb',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  hike.height,
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  'm',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 8),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Time',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  hike.time,
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  'h:m',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
