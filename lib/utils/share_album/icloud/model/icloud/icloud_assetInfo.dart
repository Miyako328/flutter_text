class ICloudAssetInfo {
  final String fileSize;
  final String width;
  final String height;
  final String url;
  final String urlExpiry;

  ICloudAssetInfo({
    required this.fileSize,
    required this.width,
    required this.height,
    required this.url,
    required this.urlExpiry,
  });

  factory ICloudAssetInfo.fromJson(Map<String, dynamic> json) {
    return ICloudAssetInfo(
      fileSize: json['fileSize'],
      width: json['width'],
      height: json['height'],
      url: json['url'],
      urlExpiry: json['urlExpiry'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileSize': fileSize,
      'width': width,
      'height': height,
      'url': url,
      'urlExpiry': urlExpiry,
    };
  }
}
