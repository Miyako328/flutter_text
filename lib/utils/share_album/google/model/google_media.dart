import 'google_user.dart';

class GoogleMedia {
  final String id;
  String? fileName;
  String? description;
  final String thumbUrl;
  final String rawUrl;
  final int width;
  final int height;
  int fileSize;
  final MediaType mediaType;
  final int duration;
  final int createdTime;
  final int uploadedTime;
  final GoogleUser? uploadUser;
  final int commentCount;

  GoogleMedia({
    required this.id,
    this.fileName,
    this.description,
    required this.thumbUrl,
    required this.rawUrl,
    required this.width,
    required this.height,
    required this.fileSize,
    required this.mediaType,
    required this.duration,
    required this.createdTime,
    required this.uploadedTime,
    this.uploadUser,
    required this.commentCount,
  });

  @override
  String toString() {
    return 'GoogleMedia{id: $id, fileName: $fileName, description: $description, thumbUrl: $thumbUrl, rawUrl: $rawUrl, width: $width, height: $height, fileSize: $fileSize, mediaType: $mediaType, duration: $duration, createdTime: $createdTime, uploadedTime: $uploadedTime, uploadUser: $uploadUser, commentCount: $commentCount}';
  }

  Map toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'description': description,
      'thumbUrl': thumbUrl,
      'rawUrl': rawUrl,
      'width': width,
      'height': height,
      'fileSize': fileSize,
      'mediaType': mediaType.toString(),
      'duration': duration,
      'createdTime': createdTime,
      'uploadedTime': uploadedTime,
      'uploadUser': uploadUser?.toJson(),
      'commentCount': commentCount,
    };
  }

  factory GoogleMedia.fromJson(Map json) {
    return GoogleMedia(
      id: json['id'],
      fileName: json['fileName'],
      description: json['description'],
      thumbUrl: json['thumbUrl'],
      rawUrl: json['rawUrl'],
      width: json['width'],
      height: json['height'],
      fileSize: json['fileSize'],
      mediaType:
          MediaType.values.firstWhere((e) => e.toString() == json['mediaType']),
      duration: json['duration'],
      createdTime: json['createdTime'],
      uploadedTime: json['uploadedTime'],
      commentCount: json['commentCount'],
    );
  }
}

enum MediaType { VIDEO, PHOTO, GIF }
