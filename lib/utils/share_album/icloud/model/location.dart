class Location {
  final String scheme;
  final List<String> hosts;

  Location({
    required this.scheme,
    this.hosts = const [],
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      scheme: json['scheme'],
      hosts: List<String>.from(json['hosts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheme': scheme,
      'hosts': hosts,
    };
  }
}
