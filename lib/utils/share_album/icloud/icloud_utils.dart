import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:self_utils/utils/log_utils.dart';
import 'model/derivative.dart';
import 'model/icloud/icloud_album.dart';
import 'model/icloud/icloud_assetInfo.dart';
import 'model/icloud/icloud_media.dart';
import 'model/web_asset_req_body.dart';
import 'model/web_asset_res.dart';
import 'model/web_stream.dart';
import 'model/web_stream_req_body.dart';

class ICloudSharedAlbumRepository {
  //// icloud album
  static Future<ICloudAlbum?> getICloudAlbum(String albumUrl) async {
    try {
      final regex = RegExp(r'^https://www\.icloud\.com/sharedalbum/#([^/]+)$');
      if (regex.hasMatch(albumUrl)) {
        // 匹配成功后的逻辑
        final albumId = regex.firstMatch(albumUrl)!.group(1)!;
        Log.info('Album URL matches the pattern. $albumId');
        final webStream = await fetchStream(albumId);
        Log.info('webStream. $webStream');
        final List<String> photoGuids = [];
        List<ICloudMedia> medias = [];
        for (final photo in webStream.photos) {
          photoGuids.add(photo.photoGuid);
        }
        if (photoGuids.isNotEmpty) {
          final data = await fetchAssetUrls(albumId, photoGuids);
          for (final photo in webStream.photos) {
            final id = photo.photoGuid;
            final userLastName = photo.contributorLastName;
            final userFirstName = photo.contributorFirstName;
            final userFullName = photo.contributorFullName;
            bool isVideo = photo.mediaAssetType?.contains('video') ?? false;
            ICloudAssetInfo? originalAsset;
            ICloudAssetInfo? lowResAsset;
            ICloudAssetInfo? coverAsset;
            Log.info('photo.dateCreated: ${photo.dateCreated}');
            if (isVideo) {
              originalAsset =
                  photo.derivatives['720p']?.convertToICloudAssetInfo(data);
              lowResAsset =
                  photo.derivatives['360p']?.convertToICloudAssetInfo(data);
              coverAsset = photo.derivatives['PosterFrame']
                  ?.convertToICloudAssetInfo(data);
            } else {
              final sizeList = photo.derivatives.keys;
              if (sizeList.isNotEmpty) {
                final sortedKeys = sizeList.toList()
                  ..sort((a, b) {
                    final aSize = int.tryParse(a) ?? 0;
                    final bSize = int.tryParse(b) ?? 0;
                    return bSize - aSize;
                  });
                final largestSize = sortedKeys.first;
                final minSize = sortedKeys.last;
                originalAsset = photo.derivatives[largestSize]
                    ?.convertToICloudAssetInfo(data);
                lowResAsset =
                    photo.derivatives[minSize]?.convertToICloudAssetInfo(data);
              }
            }

            if (originalAsset != null) {
              ICloudMedia media = ICloudMedia(
                id: id,
                originalWidth: photo.width ?? originalAsset.width,
                originalHeight: photo.height ?? originalAsset.height,
                userLastName: userLastName,
                userFirstName: userFirstName,
                userFullName: userFullName,
                isVideo: isVideo,
                originalAsset: originalAsset,
                lowerResAsset: lowResAsset,
                coverAsset: coverAsset,
                createdTime: photo.dateCreated,
              );
              medias.add(media);
            }
          }
          Log.info('WebAssetResponseData. ${jsonEncode(medias)}');
          ICloudAlbum album = ICloudAlbum(
            userFirstName: webStream.userFirstName,
            userLastName: webStream.userLastName,
            albumName: webStream.streamName,
            medias: medias,
          );
          return album;
        }
      } else {
        // 不匹配时的逻辑
        Log.info('Album URL does not match the pattern.');
        return null;
      }
    } catch (err) {
      Log.error(err.toString());
    }
    return null;
  }

  static Future<WebStream> fetchStream(String albumId) async {
    try {
      // 使用正确的iCloud API端点
      final streamUrl = 'https://p01-sharedstreams.icloud.com/$albumId/sharedstreams/webstream';

      WebStreamRequestBody params = WebStreamRequestBody(streamCtag: null);
      final ret = await _fetchStreamICloud(streamUrl, params);
      return ret;
    } catch (err) {
      Log.error(err.toString());
      rethrow;
    }
  }

  static Future<WebAssetResponseData> fetchAssetUrls(
      String albumId, List<String> photoGuids) async {
    // 使用正确的iCloud API端点
    final assetUrl = 'https://p01-sharedstreams.icloud.com/$albumId/sharedstreams/webasseturls';
    WebAssetRequestBody params = WebAssetRequestBody(photoGuids: photoGuids);
    final ret = await _fetchAssetUrlsICloud(assetUrl, params);
    return ret;
  }

  // 实现实际的API调用
  static Future<WebStream> _fetchStreamICloud(String url, WebStreamRequestBody params) async {
    try {
      Log.info('Fetching stream from URL: $url');
      
      // 构建iCloud API期望的请求体
      final requestBody = {
        'streamCtag': params.streamCtag,
        'clientBuildNumber': '2203Project42',
        'clientId': 'com.apple.CloudPhotosWeb-1.0',
      };
      
      Log.info('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Origin': 'https://www.icloud.com',
          'Referer': 'https://www.icloud.com/',
        },
        body: jsonEncode(requestBody),
      );

      Log.info('Response status: ${response.statusCode}');
      Log.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return WebStream.fromJson(jsonData);
      } else {
        // 尝试解析错误响应
        String errorMessage = 'Failed to fetch stream: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData.containsKey('errorMessage')) {
            errorMessage += ' - ${errorData['errorMessage']}';
          }
        } catch (e) {
          // 忽略JSON解析错误
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      Log.error('Error fetching stream: $e');
      rethrow;
    }
  }

  static Future<WebAssetResponseData> _fetchAssetUrlsICloud(String url, WebAssetRequestBody params) async {
    try {
      Log.info('Fetching asset URLs from URL: $url');
      
      // 构建iCloud API期望的请求体
      final requestBody = {
        'photoGuids': params.photoGuids,
        'clientBuildNumber': '2203Project42',
        'clientId': 'com.apple.CloudPhotosWeb-1.0',
      };
      
      Log.info('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Origin': 'https://www.icloud.com',
          'Referer': 'https://www.icloud.com/',
        },
        body: jsonEncode(requestBody),
      );

      Log.info('Response status: ${response.statusCode}');
      Log.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return WebAssetResponseData.fromJson(jsonData);
      } else {
        // 尝试解析错误响应
        String errorMessage = 'Failed to fetch asset URLs: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData.containsKey('errorMessage')) {
            errorMessage += ' - ${errorData['errorMessage']}';
          }
        } catch (e) {
          // 忽略JSON解析错误
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      Log.error('Error fetching asset URLs: $e');
      rethrow;
    }
  }

  static String _getBaseStreamUrl(String albumId) {
    final partition = _getPartition(albumId);
    return 'https://p$partition-sharedstreams.icloud.com';
  }

  static String _getPartition(String albumId) {
    try {
      final partition = albumId.startsWith('A')
          ? base62ToInt(albumId[1])
          : base62ToInt(albumId.substring(1, 3));
      return partition < 10 ? '0$partition' : '$partition';
    } catch (e) {
      Log.error(e.toString());
    }
    return '';
  }

  static int base62ToInt(String value) {
    const base62Chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    int result = 0;
    for (int i = 0; i < value.length; i++) {
      final index = base62Chars.indexOf(value[i]);
      if (index == -1) {
        throw ArgumentError('Invalid base62 character: ${value[i]}');
      }
      result = result * 62 + index;
    }
    return result;
  }
}

extension DerivativeExtension on Derivative {
  ICloudAssetInfo? convertToICloudAssetInfo(WebAssetResponseData webAsset) {
    final asset = webAsset.items[checksum];
    if (asset == null) return null;

    final location = webAsset.locations[asset.urlLocation];
    final scheme = location?.scheme ?? "https";
    final host = location != null && location.hosts.isNotEmpty == true
        ? location.hosts.first
        : asset.urlLocation;
    final url = '$scheme://$host${asset.urlPath}';
    final urlExpiry = parseDate(asset.urlExpiry) ?? 0;

    return ICloudAssetInfo(
      fileSize: fileSize,
      width: width,
      height: height,
      url: url,
      urlExpiry: urlExpiry.toString(),
    );
  }
}

DateTime? parseDate(String dateStr) {
  try {
    final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    return format.parse(dateStr);
  } catch (e) {
    Log.info('Error parsing date: $e');
    return null;
  }
}
