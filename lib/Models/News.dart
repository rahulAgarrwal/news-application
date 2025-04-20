class News {
  String? id;
  String title;
  String publishedTime;
  String imageUrl;
  String webUrl;
  String description;
  String authorName;
  News({this.id,required this.title, required this.publishedTime, required this.imageUrl, required this.webUrl,required this.description,required this.authorName});
 Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'publishedTime': publishedTime,
      'imageUrl': imageUrl,
      'webUrl': webUrl,
      'description': description,
      'authorName': authorName,
    };

    // We don't add the id to the map if it's null
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
    factory News.fromMap(Map<String, dynamic> map) {
    return News(
      id: map['id'],  // SQLite will have assigned a unique ID when retrieving
      title: map['title'],
      publishedTime: map['publishedTime'],
      imageUrl: map['imageUrl'],
      webUrl: map['webUrl'],
      description: map['description'],
      authorName: map['authorName'],
    );
  }

}
