class AuthActionResult {
  const AuthActionResult({
    required this.message,
    this.success = true,
  });

  final String message;
  final bool success;

  factory AuthActionResult.fromJson(Map<String, dynamic> json) {
    final message = json['message']?.toString().trim();
    return AuthActionResult(
      message: (message == null || message.isEmpty)
          ? 'İşlem başarıyla tamamlandı.'
          : message,
      success: json['success'] == true,
    );
  }
}
