import 'icloud_media.dart';

class ICloudAlbum {
  final String userLastName;
  final String userFirstName;
  final String albumName;
  final List<ICloudMedia> medias;

  ICloudAlbum({
    required this.userLastName,
    required this.userFirstName,
    required this.albumName,
    this.medias = const [],
  });

  factory ICloudAlbum.fromJson(Map<String, dynamic> json) {
    return ICloudAlbum(
      userLastName: json['userLastName'],
      userFirstName: json['userFirstName'],
      albumName: json['albumName'],
      medias: List<ICloudMedia>.from(
          json['medias'].map((x) => ICloudMedia.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userLastName': userLastName,
      'userFirstName': userFirstName,
      'albumName': albumName,
      'medias': medias.map((x) => x.toJson()).toList(),
    };
  }
}
