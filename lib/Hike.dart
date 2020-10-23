class Hike {
  String title;
  double length;
  double lengthMiles;
  double height;
  double heightFeet;
  String story;
  String storyShort;
  String photo;
  List<String> photos;
  String id;
  List<double> data;
  double time;
  String startTitle;
  String endTitle;
  String startSubTitle;
  String endSubTitle;
  String dataString;


  Hike({
    this.title,
    this.story,
    this.photo,
    this.id,
    this.data,
    this.length,
    this.height,
    this.heightFeet,
    this.lengthMiles,
    this.photos,
    this.time,
    this.storyShort,
    this.endSubTitle,
    this.endTitle,
    this.startSubTitle,
    this.startTitle,
    this.dataString,
  });
}
