class Derivative {
  final String checksum;
  final String fileSize;
  final String width;
  final String height;
  final String? state;

  Derivative({
    required this.checksum,
    required this.fileSize,
    required this.width,
    required this.height,
    this.state,
  });

  factory Derivative.fromJson(Map<String, dynamic> json) {
    return Derivative(
      checksum: json['checksum'],
      fileSize: json['fileSize'],
      width: json['width'],
      height: json['height'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checksum': checksum,
      'fileSize': fileSize,
      'width': width,
      'height': height,
      'state': state,
    };
  }
}
