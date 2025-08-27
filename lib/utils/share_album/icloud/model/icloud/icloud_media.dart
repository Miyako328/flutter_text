import 'icloud_assetInfo.dart';

class ICloudMedia {
  final String id;
  final String userLastName;
  final String userFirstName;
  final String userFullName;
  final String createdTime;
  final String originalWidth;
  final String originalHeight;
  final bool isVideo;
  final ICloudAssetInfo originalAsset;
  final ICloudAssetInfo? lowerResAsset;
  final ICloudAssetInfo? coverAsset;

  ICloudMedia({
    required this.id,
    required this.userLastName,
    required this.userFirstName,
    required this.userFullName,
    required this.createdTime,
    required this.originalWidth,
    required this.originalHeight,
    required this.isVideo,
    required this.originalAsset,
    this.lowerResAsset,
    this.coverAsset,
  });

  factory ICloudMedia.fromJson(Map<String, dynamic> json) {
    return ICloudMedia(
      id: json['id'],
      userLastName: json['userLastName'],
      userFirstName: json['userFirstName'],
      userFullName: json['userFullName'],
      createdTime: json['createdTime'],
      originalWidth: json['originalWidth'],
      originalHeight: json['originalHeight'],
      isVideo: json['isVideo'],
      originalAsset: ICloudAssetInfo.fromJson(json['originalAsset']),
      lowerResAsset: json['lowerResAsset'] != null
          ? ICloudAssetInfo.fromJson(json['lowerResAsset'])
          : null,
      coverAsset: json['coverAsset'] != null
          ? ICloudAssetInfo.fromJson(json['coverAsset'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userLastName': userLastName,
      'userFirstName': userFirstName,
      'userFullName': userFullName,
      'createdTime': createdTime,
      'originalWidth': originalWidth,
      'originalHeight': originalHeight,
      'isVideo': isVideo,
      'originalAsset': originalAsset.toJson(),
      'lowerResAsset': lowerResAsset?.toJson(),
      'coverAsset': coverAsset?.toJson(),
    };
  }
}
