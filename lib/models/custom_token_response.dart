class CustomTokenResponse {
  final bool success;
  final String? customToken;
  final String? error;
  final String? message;

  CustomTokenResponse({
    required this.success,
    this.customToken,
    this.error,
    this.message,
  });

  factory CustomTokenResponse.fromJson(Map<String, dynamic> json) {
    return CustomTokenResponse(
      success: json['success'] ?? false,
      customToken: json['customToken'],
      error: json['error'],
      message: json['message'],
    );
  }
}
