class VideoUtils {
  /// Extract YouTube video ID from any valid URL
  static String? getYouTubeId(String url) {
    final RegExp regExp = RegExp(
      r'(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );

    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  /// Extract Vimeo video ID
  static String? getVimeoId(String url) {
    final RegExp regExp = RegExp(
      r'vimeo\.com\/(?:video\/)?([0-9]+)',
    );

    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}
