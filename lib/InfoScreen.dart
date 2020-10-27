import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ihikepakistan/PhotoScreen.dart';
import 'package:ihikepakistan/ReadScreen.dart';
import 'package:ihikepakistan/ShareTile.dart';
import 'Hike.dart';
import 'MapScreen.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;



class InfoScreen extends StatelessWidget {
  final Hike hike;

  InfoScreen({this.hike});

  Widget build(BuildContext context) {
    return Hero(
      tag: hike.title + 'tag',
      child: Scaffold(
        appBar: AppBar(
          title: Text(hike.title),
          actions: [IconButton(
              icon: Icon(Icons.edit),
              onPressed: (){
                url_launcher.launch('https://docs.google.com/forms/d/e/1FAIpQLSfM6y1DTj6oIQD-e1Yzj0KfBcoWLaa-viUKaV_pg7BVS4FWCg/viewform?usp=pp_url&entry.1690278709=${hike.title}&entry.1645486241=${hike.story}&entry.2003551559=${hike.title}', forceWebView: true, enableJavaScript: true);
              },
          )]
        ),
        body: InfoBody(hike: hike,),
        /*floatingActionButton: FloatingActionButton(
          child: Icon(Icons.map),
          heroTag: null,
          onPressed: (){},
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,*/
      ),
    );
  }
}

class InfoBody extends StatelessWidget {
  final Hike hike;

  InfoBody({this.hike});

  /*void setReview(BuildContext context, int value) async {
    if(prefs.getInt(hike.id+'rating') != null){
      await Firestore.instance.runTransaction((transaction) async {
        String oldStar = ['star1', 'star2', 'star3', 'star4', 'star5'][prefs.getInt(hike.id+'rating')-1];
        DocumentSnapshot document = await transaction.get(Firestore.instance.document('ratings/${hike.id}'));
        transaction.update(Firestore.instance.document('ratings/${hike.id}'), {oldStar : document.data[oldStar] - 1});
      });
    }
    String star = ['star1', 'star2', 'star3', 'star4', 'star5'][value-1];
    await Firestore.instance.runTransaction((transaction) async {
      DocumentReference documentReference = Firestore.instance.document('ratings/${hike.id}');
      DocumentSnapshot document = await transaction.get(documentReference);
      var data = document.data;
      data[star]++;
      transaction.update(documentReference, {star : data[star]});
      transaction.update(Firestore.instance.document('ratings/allratings'), {hike.id :
        (data['star1'] + data['star2']*2 + data['star3']*3 + data['star4']*4 + data['star5']*5) /
        (data['star1'] + data['star2'] + data['star3'] + data['star4'] + data['star5'])
      });
    });
    await prefs.setInt(hike.id+'rating', value);
    showDialog(
      context: context,
      child: SimpleDialog(
        title: Text('Thank you for Rating!'),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*AbsorbPointer(
                absorbing: true,
                child: RatingBar(
                  onRatingUpdate: (double value){},
                  allowHalfRating: true,
                  initialRating: value.toDouble(),
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.amber,),
                    half: Icon(Icons.star_half, color: Colors.amber,),
                    empty: Icon(Icons.star_border, color: Colors.grey,),
                  ),
                  itemCount: 5,
                ),
              ),*/
            ],
          ),
        ],
      ),
    );
  }*/


  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 250,
          flexibleSpace: Image.asset(
            hike.photo,
            alignment: Alignment.topCenter,
            fit: BoxFit.cover,
            height: 250,
            errorBuilder: (BuildContext context, Object object, StackTrace stackTrace){
              return Image.network(
                hike.photos[0],
                alignment: Alignment.topCenter,
                fit: BoxFit.cover,
                height: 250,
                errorBuilder: (BuildContext context, Object object, StackTrace stackTrace){
                  return Center(
                    child: Icon(Icons.broken_image, size: 30,),
                  );
                },
              );
            },
          ),
          /*actions: <Widget>[
            IconButton(icon: Icon(hike.icon), onPressed: null)
          ],*/
          leading: Container(),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return [
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text(
                    'Go To Map',
                  ),
                  trailing: Icon(Icons.navigate_next),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(
                          hike: hike,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.straighten),
                  title: Text(
                    'Length:',
                  ),
                  subtitle: Text('${hike.length}km'),
                ),
                ListTile(
                  leading: Icon(Icons.import_export),
                  title: Text(
                    'Climb:',
                  ),
                  subtitle: Text('${hike.height}m'),
                ),
                ListTile(
                  leading: Icon(Icons.schedule),
                  title: Text(
                    'Average Time:',
                  ),
                  subtitle: Text('${hike.time} min'),
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Description:\n'),
                  subtitle: Text(hike.storyShort + '\n'),
                  /*trailing: SizedBox(
                    child: IconButton(
                      icon: Icon(Icons.fullscreen),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => ReadScreen(
                              hike: hike,
                            ),
                          ),
                        );
                      },
                      padding: EdgeInsets.all(0),
                    ),
                    width: 30,
                  ),*/
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => ReadScreen(
                          hike: hike,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      pauseAutoPlayOnManualNavigate: true,
                      pauseAutoPlayOnTouch: true,
                      autoPlayInterval: Duration(seconds: 6),
                      autoPlayAnimationDuration: Duration(milliseconds: 500),
                      pauseAutoPlayInFiniteScroll: false,
                      viewportFraction: 0.7,
                    ),
                    itemCount: hike.photos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        //color: Colors.red,
                        width: 266,
                        child: GestureDetector(
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            //child: Image.network(hike.photos[index]),
                            child: Image.network(
                              hike.photos[index],
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object object, StackTrace stackTrace){
                                return Center(
                                  child: Icon(Icons.broken_image, size: 30,),
                                );
                              },
                              /*loadingBuilder: (BuildContext context, Widget widget, ImageChunkEvent event){
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },*/
                            ),
                          ),
                          onTap: () {
                            openPhotos(index, context);
                          },
                        ),
                      );
                    },
                  ),
                ),
                ShareTile(msg: 'This is ${hike.title}'),
                /*Row(
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                        return RatingBar(
                          onRatingUpdate: (double value){
                            setReview(context, value.toInt());
                          },
                          initialRating: rating ?? 5,
                          allowHalfRating: true,
                          itemCount: 5,
                          ratingWidget: RatingWidget(
                            empty: Icon(Icons.star_border, color: Colors.grey,),
                            half: Icon(Icons.star_half, color: Colors.amber,),
                            full: Icon(Icons.star, color: Colors.amber,),
                          ),
                          itemSize: 50,
                          itemPadding: EdgeInsets.all(15),
                          tapOnlyMode: true,
                          glow: false,
                        );
                      },
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),*/
                Container(height: 20,),
              ][index];
            },
            childCount: 8,
          ),
        ),
      ],
    );
  }

  void openPhotos(int index, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => PhotoScreen(
          hike: hike,
          index: index,
        ),
      ),
    );
  }
}
