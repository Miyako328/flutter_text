class Asset {
  final String urlExpiry;
  final String urlLocation;
  final String urlPath;

  Asset({
    required this.urlExpiry,
    required this.urlLocation,
    required this.urlPath,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      urlExpiry: json['url_expiry'],
      urlLocation: json['url_location'],
      urlPath: json['url_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url_expiry': urlExpiry,
      'url_location': urlLocation,
      'url_path': urlPath,
    };
  }
}
