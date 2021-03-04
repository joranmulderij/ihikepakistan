class Hike {
  String title;
  String length;
  //String lengthMiles;
  String height;
  //double heightFeet;
  String story;
  String storyShort;
  String photo;
  List<String> photos;
  String time;
  String difficulty;
  String tags;
  List<List<double>> multiData;
  bool unlisted;
  //String startTitle;
  //String endTitle;
  //String startSubTitle;
  //String endSubTitle;
  //String dataString;

  Hike(
      {this.title,
      this.story,
      this.photo,
      this.length,
      this.height,
      this.photos,
      this.time,
      this.storyShort,
      this.difficulty,
      this.tags,
      this.multiData,
      this.unlisted});
}
