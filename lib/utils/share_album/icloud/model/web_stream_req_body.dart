class WebStreamRequestBody {
  final String? streamCtag;

  WebStreamRequestBody({
    this.streamCtag,
  });

  factory WebStreamRequestBody.fromJson(Map<String, dynamic> json) {
    return WebStreamRequestBody(
      streamCtag: json['streamCtag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streamCtag': streamCtag,
    };
  }
}
