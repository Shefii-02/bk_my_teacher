class AppleAuthResult {
  final bool    status;
  final String  message;
  final String? token;
  final String? name;
  final String? email;
  final Map<String, dynamic>? user;

  AppleAuthResult({
    required this.status,
    required this.message,
    this.token,
    this.name,
    this.email,
    this.user,
  });

  factory AppleAuthResult.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return AppleAuthResult(
      // ✅ handles both 'status: true' and 'success: true' from Laravel
      status  : json['status']  == true || json['success'] == true,
      message : json['message'] as String? ?? '',
      token   : json['token']   as String?,
      name    : user['name']    as String?,
      email   : user['email']   as String?,
      user    : user,
    );
  }
}