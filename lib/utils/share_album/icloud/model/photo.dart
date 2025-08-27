import 'derivative.dart';

class Photo {
  final String batchGuid;
  final Map<String, Derivative> derivatives;
  final String contributorLastName;
  final String batchDateCreated;
  final String dateCreated;
  final String contributorFirstName;
  final String photoGuid;
  final String contributorFullName;
  final String? mediaAssetType;
  final String caption;
  final String? width;
  final String? height;

  Photo({
    required this.batchGuid,
    this.derivatives = const {},
    required this.contributorLastName,
    required this.batchDateCreated,
    required this.dateCreated,
    required this.contributorFirstName,
    required this.photoGuid,
    required this.contributorFullName,
    this.mediaAssetType,
    required this.caption,
    this.width,
    this.height,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      batchGuid: json['batchGuid'],
      derivatives: Map.from(json['derivatives'])
          .map((k, v) => MapEntry(k, Derivative.fromJson(v))),
      contributorLastName: json['contributorLastName'],
      batchDateCreated: json['batchDateCreated'],
      dateCreated: json['dateCreated'],
      contributorFirstName: json['contributorFirstName'],
      photoGuid: json['photoGuid'],
      contributorFullName: json['contributorFullName'],
      mediaAssetType: json['mediaAssetType'],
      caption: json['caption'],
      width: json['width'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchGuid': batchGuid,
      'derivatives': derivatives.map((k, v) => MapEntry(k, v.toJson())),
      'contributorLastName': contributorLastName,
      'batchDateCreated': batchDateCreated,
      'dateCreated': dateCreated,
      'contributorFirstName': contributorFirstName,
      'photoGuid': photoGuid,
      'contributorFullName': contributorFullName,
      'mediaAssetType': mediaAssetType,
      'caption': caption,
      'width': width,
      'height': height,
    };
  }
}
