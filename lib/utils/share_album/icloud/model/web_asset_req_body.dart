class WebAssetRequestBody {
  final List<String> photoGuids;

  WebAssetRequestBody({
    this.photoGuids = const [],
  });

  factory WebAssetRequestBody.fromJson(Map<String, dynamic> json) {
    return WebAssetRequestBody(
      photoGuids: List<String>.from(json['photoGuids']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photoGuids': photoGuids,
    };
  }
}
