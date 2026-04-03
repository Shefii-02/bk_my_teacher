class AppConstants {
  // ── Change these to your server URLs ──────────────────────
  static const String baseUrl      = 'http://192.168.29.145:3000';
  static const String socketUrl    = 'http://192.168.29.145:3000';
  static const String apiUrl       = '$baseUrl/api';
  static const String uploadUrl    = '$apiUrl/upload';

  // Pagination
  static const int messagesPageSize = 30;
}