class VideoUtils {
  /// Extract YouTube video ID from ALL valid YouTube URLs
  static String? getYouTubeId(String url) {
    if (url.isEmpty) return null;

    // Normalize
    url = url.trim();

    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;

    // youtu.be/<id>
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    // youtube.com domain
    if (uri.host.contains('youtube.com') || uri.host.contains('m.youtube.com')) {
      // watch?v=<id>
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      }

      // /embed/<id>
      // /shorts/<id>
      // /live/<id>
      // /v/<id>
      final paths = uri.pathSegments;
      final knownPaths = ['embed', 'shorts', 'live', 'v'];

      if (paths.length >= 2 && knownPaths.contains(paths[0])) {
        return paths[1];
      }
    }

    return null;
  }

  /// Extract Vimeo video ID
  static String? getVimeoId(String url) {
    if (url.isEmpty) return null;

    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('vimeo.com')) {
      return uri.pathSegments.firstWhere(
            (s) => RegExp(r'^\d+$').hasMatch(s),
        orElse: () => '',
      );
    }

    return null;
  }
}
