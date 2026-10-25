class GakokenException implements Exception {
  final String message;
  final bool isWarning;
  final Map<String, dynamic>? metadata;

  GakokenException(this.message, {this.isWarning = false, this.metadata});

  @override
  String toString() => message;
}
