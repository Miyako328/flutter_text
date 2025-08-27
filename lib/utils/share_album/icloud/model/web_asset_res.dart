import 'asset.dart';
import 'location.dart';

class WebAssetResponseData {
  final Map<String, Location> locations;
  final Map<String, Asset> items;

  WebAssetResponseData({
    this.locations = const {},
    this.items = const {},
  });

  factory WebAssetResponseData.fromJson(Map<String, dynamic> json) {
    return WebAssetResponseData(
      locations: Map.from(json['locations'])
          .map((k, v) => MapEntry(k, Location.fromJson(v))),
      items:
          Map.from(json['items']).map((k, v) => MapEntry(k, Asset.fromJson(v))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locations': locations.map((k, v) => MapEntry(k, v.toJson())),
      'items': items.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}
