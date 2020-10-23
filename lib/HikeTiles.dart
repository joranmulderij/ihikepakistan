import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Hike.dart';
import 'MapScreen.dart';
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
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
      width: 300,
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
          tag: hike.id + 'tag',
          child: Card(
            elevation: 5,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(hike.title),
                  subtitle: Text('${(hike.length % 1 == 0) ? hike.length.round() : hike.length}km (${(hike.lengthMiles % 1 == 0) ? hike.lengthMiles.round() : hike.lengthMiles}mi)'),
                ),
                Image.asset(
                  hike.photo,
                  fit: BoxFit.cover,
                  height: 215,
                  width: 300,
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(children: [
                      Text('Length', style: TextStyle(color: Colors.grey, fontSize: 12),),
                      Text(hike.length.toStringAsFixed(2), style: TextStyle(fontSize: 20),),
                      Text('Km', style: TextStyle(color: Colors.grey, fontSize: 8),),
                    ],),
                    Column(children: [
                      Text('Climb', style: TextStyle(color: Colors.grey, fontSize: 12),),
                      Text(hike.height.toInt().toString(), style: TextStyle(fontSize: 20),),
                      Text('m', style: TextStyle(color: Colors.grey, fontSize: 8),),
                    ],),
                    Column(children: [
                      Text('Time', style: TextStyle(color: Colors.grey, fontSize: 12),),
                      Text(hike.time.toInt().toString()+':'+((hike.time%1)*60).toInt().toString().padLeft(2, '0'), style: TextStyle(fontSize: 20),),
                      Text('h:m', style: TextStyle(color: Colors.grey, fontSize: 8),),
                    ],),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


