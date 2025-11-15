import 'package:BookMyTeacher/presentation/widgets/vimeo_embed.dart';
import 'package:flutter/material.dart';
import '../widgets/youtube_embed.dart';
import '../widgets/doubt_clear_section.dart';

class RecordedVideoWithDoubt extends StatelessWidget {
  final String title;
  final String videoUrl;

  const RecordedVideoWithDoubt({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VimeoEmbed(videoId: '8870338',),
            YoutubeEmbed(videoId: 'HhjHYkPQ8F0',),
            const SizedBox(height: 20),
            const DoubtClearSection(),
            YouTubeVideoPlayer( videoId: 'uM3Bjbskv48')
          ],
        ),
      ),
    );
  }
}
