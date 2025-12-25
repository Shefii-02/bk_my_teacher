import 'package:BookMyTeacher/presentation/widgets/vimeo_embed.dart';
import 'package:flutter/material.dart';
import '../../core/constants/youtube_utils.dart';
import '../widgets/youtube_embed.dart';
import '../widgets/doubt_clear_section.dart';
import '../widgets/youtube_live_chat.dart';

class RecordedVideoWithDoubt extends StatelessWidget {
  final String title;
  final String classId;
  final String type;
  final String videoUrl;

  const RecordedVideoWithDoubt({
    super.key,
    required this.title,
    required this.videoUrl, required this.classId, required this.type,
  });

  @override
  Widget build(BuildContext context) {
    String? videoId;
    videoId = VideoUtils.getYouTubeId(videoUrl);
print(type);
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
            // YoutubeEmbed(videoId: 'HhjHYkPQ8F0',),uM3Bjbskv48
            if (videoId == null)
              const Center(
                child: Text(
                  'Invalid video URL',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            YouTubeVideoPlayer( videoId: videoId!),
            // YouTubeLiveChat(videoId: "No0B2G5BHjM"),
            const SizedBox(height: 20),
            DoubtClearSection(
              type: type,
              classId: classId,
            ),
          ],
        ),
      ),
    );
  }
}


