import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:self_utils/utils/log_utils.dart';
import 'model/google_album.dart';
import 'model/google_comment.dart';
import 'model/google_media.dart';
import 'model/google_user.dart';

class GoogleAlbumRepository {
  static String baseUrl =
      'https://photos.google.com/_/PhotosUi/data/batchexecute';

  static Future<GoogleAlbum?> getAlbumData(String sharedAlbumUrl) async {
    String albumUrl = sharedAlbumUrl.startsWith("https://")
        ? sharedAlbumUrl
        : "https://$sharedAlbumUrl";
    final shortRegex = RegExp(r"^https://photos\.app\.goo\.gl/[^/]+$");
    if (shortRegex.hasMatch(albumUrl)) {
      final response = await http.get(Uri.parse(albumUrl));
      if (response.statusCode == 302) {
        final location = response.headers['location'];
        Log.info('location: $location');
        if (location != null) {
          albumUrl = location;
        } else {
          Log.error("Parse short album url location error");
        }
      } else {
        RegExp regex = RegExp(r'<link\s+rel="canonical"\s+href="([^"]+)"');
        Match? match = regex.firstMatch(response.body);

        if (match != null) {
          albumUrl = match.group(1)!;
          Log.info('Extracted URL: $albumUrl');
        } else {
          Log.error('No match found');
        }
      }
    }

    final longRegex = RegExp(r"^https://photos\.google\.com/share/[^/]+$");
    if (longRegex.hasMatch(albumUrl)) {
      final url = Uri.parse(albumUrl);
      final albumId = url.pathSegments.last;
      final albumKey = url.queryParameters['key'];
      Log.info('albumId: $albumId, albumKey: $albumKey');
      if (albumId.isNotEmpty && albumKey != null) {
        final response = await fetchAlbumData(albumId, albumKey);
        Log.info('response: ${jsonEncode(response)}');
        return response;
      }
    }
    return null;
  }

  /// 相册详情
  static Future<GoogleAlbum?> fetchAlbumData(
      String albumId, String albumKey) async {
    try {
      final params =
          "[[[\"snAcKc\",\"[\\\"$albumId\\\",null,null,\\\"$albumKey\\\",0]\",null,\"generic\"]]]";
      final res = await http.post(Uri.parse(baseUrl), body: {"f.req": params});
      if (res.statusCode == 200) {
        final json = res.body;
        GoogleAlbum album = parseAlbumResult(json, albumKey);
        Log.info('album: ${jsonEncode(album)}');
        return album;
      }
      return null;
    } catch (err) {
      Log.error(err.toString());
      return null;
    }
  }

  static GoogleAlbum parseAlbumResult(String result, String albumKey) {
    final json = result.split('\n')[2];
    final jsonElement = jsonDecode(json);
    final dataStr = jsonElement[0][2].toString();
    final dataArray = jsonDecode(dataStr);

    final albumDataArray = dataArray[3];
    final albumId = albumDataArray[0];
    final albumName = albumDataArray[1];
    final dateRangeArray = albumDataArray[2];
    final dateRangeStart = dateRangeArray[0];
    final dateRangeEnd = dateRangeArray[1];
    final zipUrl = albumDataArray[3];
    final coverUrl = albumDataArray[4][0];
    final ownerId = albumDataArray[5][0];

    final members = <GoogleUser>[];
    final userDataArray = albumDataArray[28];
    for (final userData in userDataArray) {
      final memberDataArray = userData;
      final userId = memberDataArray[0][0];
      final userName = memberDataArray[3][0];
      final avatarUrl = memberDataArray[11][0];
      members.add(
          GoogleUser(userId: userId, userName: userName, avatarUrl: avatarUrl));
    }

    final medias = <GoogleMedia>[];
    final mediaDataArray = dataArray[1];
    for (final mediaData in mediaDataArray) {
      final mediaDetailArray = mediaData;
      final id = mediaDetailArray[0];
      final imageArray = mediaDetailArray[1];
      var thumbUrl = imageArray[0];
      var rawUrl = '$thumbUrl=d';
      var width = imageArray[1];
      var height = imageArray[2];
      final createdTime = mediaDetailArray[2];
      final uploadedTime = mediaDetailArray[5];
      final uploadUserId = mediaDetailArray[6][0];
      GoogleUser? uploadUser;
      if (members.any((e) => e.userId == uploadUserId)) {
        uploadUser = members.firstWhere((user) => user.userId == uploadUserId);
      }
      int commentCount =
          mediaDetailArray.length > 9 ? mediaDetailArray[9] ?? 0 : 0;
      MediaType mediaType = MediaType.PHOTO;
      int duration = 0;
      final contentObject = mediaDetailArray.last;
      if (contentObject.containsKey('76647426')) {
        mediaType = MediaType.VIDEO;
        rawUrl = '$thumbUrl=dv';
        thumbUrl = '$thumbUrl=no';
        final videoDataArray = contentObject['76647426'];
        duration = videoDataArray[0];
        width = videoDataArray[2];
        height = videoDataArray[3];
      } else if (contentObject.containsKey('139842850')) {
        mediaType = MediaType.GIF;
      }
      medias.add(GoogleMedia(
        id: id,
        thumbUrl: thumbUrl,
        rawUrl: rawUrl,
        width: width,
        height: height,
        fileSize: 0,
        mediaType: mediaType,
        duration: duration,
        createdTime: createdTime,
        uploadedTime: uploadedTime,
        uploadUser: uploadUser,
        commentCount: commentCount,
      ));
    }

    return GoogleAlbum(
      albumId: albumId,
      albumKey: albumKey,
      albumName: albumName,
      dateRangeStart: dateRangeStart,
      dateRangeEnd: dateRangeEnd,
      coverUrl: coverUrl,
      zipUrl: zipUrl,
      ownerId: ownerId,
      members: members,
      medias: medias,
    );
  }

  /// 获取文件详情
  static Future<GoogleMedia> fetchMediaData(
      GoogleMedia media, String albumKey) async {
    try {
      final params =
          "[[[\"fDcn4b\",\"[\\\"${media.id}\\\",0.8999999761581421,\\\"$albumKey\\\",null,null,[2]]\",null,\"1\"]]]";

      final res = await http.post(Uri.parse(baseUrl), body: {"f.req": params});
      if (res.statusCode == 200) {
        media = parseResultAndFillMediaData(res.body, media);
      }
    } catch (err) {
      Log.error(err.toString());
    }

    return media;
  }

  static GoogleMedia parseResultAndFillMediaData(
      String result, GoogleMedia media) {
    final lines = result.split('\n');
    final json = lines[2];
    final jsonElement = jsonDecode(json);
    final dataStr = jsonElement[0][2] as String;
    final dataArray = jsonDecode(dataStr)[0] as List<dynamic>;

    final id = dataArray[0] as String;
    final description = dataArray[1] as String;
    final fileName = dataArray[2] as String;
    final createdTime = dataArray[3] as int;
    final fileSize = dataArray[5] as int;
    final width = dataArray[6] as int;
    final height = dataArray[7] as int;

    if (id == media.id) {
      media.fileName = fileName;
      media.description = description;
      media.fileSize = fileSize;
      // 其它数据在相册数据中就已经解析到了
    }
    return media;
  }

  // 获取评论
  static Future<List<GoogleComment>> fetchCommentData(
      String mediaId, String albumId, String albumKey) async {
    List<GoogleComment> comments = [];
    try {
      final params =
          "[[[\"sq0lWe\",\"[[\\\"$mediaId\\\"],\\\"$albumKey\\\",null,[\\\"$albumId\\\"]]\",null,\"generic\"]]]";

      final res = await http.post(Uri.parse(baseUrl), body: {"f.req": params});
      if (res.statusCode == 200) {
        final json = res.body;
        comments = parseCommentResult(json);
        Log.info('comments: ${jsonEncode(comments)}');
      }
      return comments;
    } catch (err) {
      return comments;
    }
  }

  static List<GoogleComment> parseCommentResult(String result) {
    final lines = result.split('\n');
    final json = lines[2];
    final jsonElement = jsonDecode(json);
    final dataStr = jsonElement[0][2] as String;
    final dataArray = jsonDecode(dataStr)[1] as List<dynamic>;

    final comments = <GoogleComment>[];
    for (var data in dataArray) {
      final commentDataArray = data as List<dynamic>;
      final commentType =
          commentDataArray[0] == 1 ? CommentType.COMMENT : CommentType.FAVORITE;

      if (commentType == CommentType.COMMENT) {
        final commentDetailArray = commentDataArray[1] as List<dynamic>;
        final contentDetailArray = commentDetailArray[2] as List<dynamic>;
        final comment = contentDetailArray[0][0][0][1] as String;
        final createdTime = contentDetailArray[1] as int;
        final userDataArray = commentDetailArray[5] as List<dynamic>;
        final userId = userDataArray[0][1] as String;
        final userName = userDataArray[3][0] as String;
        final avatarUrl = userDataArray[11][0] as String;
        final user = GoogleUser(
            userId: userId, userName: userName, avatarUrl: avatarUrl);
        comments.add(GoogleComment(
            type: commentType,
            comment: comment,
            createdTime: createdTime,
            user: user));
      } else {
        final commentDetailArray = commentDataArray[2] as List<dynamic>;
        final userDataArray = commentDetailArray[1] as List<dynamic>;
        final userId = userDataArray[0] as String;
        final userName = userDataArray[11][0] as String;
        final avatarUrl = userDataArray[12][0] as String;
        final createdTime = commentDetailArray.last as int;
        final user = GoogleUser(
            userId: userId, userName: userName, avatarUrl: avatarUrl);
        comments.add(GoogleComment(
            type: commentType,
            comment: null,
            createdTime: createdTime,
            user: user));
      }
    }
    return comments;
  }
}
