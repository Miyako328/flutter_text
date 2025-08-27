import 'package:flutter_text/utils/share_album/icloud/model/photo.dart';

class WebStream {
  final String userLastName;
  final String userFirstName;
  final String streamCtag;
  final String streamName;
  final List<Photo> photos;

  WebStream({
    required this.userLastName,
    required this.userFirstName,
    required this.streamCtag,
    required this.streamName,
    this.photos = const [],
  });

  factory WebStream.fromJson(Map<String, dynamic> json) {
    return WebStream(
      userLastName: json['userLastName'],
      userFirstName: json['userFirstName'],
      streamCtag: json['streamCtag'],
      streamName: json['streamName'],
      photos: List<Photo>.from(json['photos'].map((x) => Photo.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userLastName': userLastName,
      'userFirstName': userFirstName,
      'streamCtag': streamCtag,
      'streamName': streamName,
      'photos': photos.map((x) => x.toJson()).toList(),
    };
  }
}
