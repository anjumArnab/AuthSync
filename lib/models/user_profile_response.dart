class UserProfileResponse {
  final bool success;
  final Map<String, dynamic>? user;
  final String? error;
  final String? message;

  UserProfileResponse({
    required this.success,
    this.user,
    this.error,
    this.message,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'] ?? false,
      user: json['user'],
      error: json['error'],
      message: json['message'],
    );
  }
}
