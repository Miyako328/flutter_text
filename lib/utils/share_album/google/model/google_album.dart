import 'google_media.dart';
import 'google_user.dart';

class GoogleAlbum {
  final String albumId;
  final String albumKey;
  final String albumName;
  final int dateRangeStart;
  final int dateRangeEnd;
  final String coverUrl;
  final String zipUrl;
  final String ownerId;
  final List<GoogleUser> members;
  final List<GoogleMedia> medias;

  GoogleAlbum({
    required this.albumId,
    required this.albumKey,
    required this.albumName,
    required this.dateRangeStart,
    required this.dateRangeEnd,
    required this.coverUrl,
    required this.zipUrl,
    required this.ownerId,
    this.members = const [],
    this.medias = const [],
  });

  @override
  String toString() {
    return 'GoogleAlbum{albumId: $albumId, albumKey: $albumKey, albumName: $albumName, dateRangeStart: $dateRangeStart, dateRangeEnd: $dateRangeEnd, coverUrl: $coverUrl, zipUrl: $zipUrl, ownerId: $ownerId, members: $members, medias: $medias}';
  }

  Map<String, dynamic> toJson() {
    return {
      'albumId': albumId,
      'albumKey': albumKey,
      'albumName': albumName,
      'dateRangeStart': dateRangeStart,
      'dateRangeEnd': dateRangeEnd,
      'coverUrl': coverUrl,
      'zipUrl': zipUrl,
      'ownerId': ownerId,
      'members': members.map((member) => member.toJson()).toList(),
      'medias': medias.map((media) => media.toJson()).toList(),
    };
  }

  factory GoogleAlbum.fromJson(Map<String, dynamic> json) {
    return GoogleAlbum(
      albumId: json['albumId'],
      albumKey: json['albumKey'],
      albumName: json['albumName'],
      dateRangeStart: json['dateRangeStart'],
      dateRangeEnd: json['dateRangeEnd'],
      coverUrl: json['coverUrl'],
      zipUrl: json['zipUrl'],
      ownerId: json['ownerId'],
      medias: (json['medias'] as List<dynamic>)
          .map((mediaJson) => GoogleMedia.fromJson(mediaJson))
          .toList(),
      members: (json['members'] as List<dynamic>)
          .map((memberJson) => GoogleUser.fromJson(memberJson))
          .toList(),
    );
  }
}
