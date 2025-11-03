import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/api_service.dart'; // adjust path as needed

class SocialMediaIcons extends StatefulWidget {
  const SocialMediaIcons({super.key});

  @override
  State<SocialMediaIcons> createState() => _SocialMediaIconsState();
}

class _SocialMediaIconsState extends State<SocialMediaIcons> {
  List<dynamic> _socialLinks = [];

  @override
  void initState() {
    super.initState();
    _loadSocialLinks();
  }

  Future<void> _loadSocialLinks() async {
    final data = await ApiService()
        .fetchSocialLinks(); // ✅ call from your service
    setState(() {
      _socialLinks = data;
    });
  }

  // void _openLink(String url) async {
  //   final uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(
  //       uri,
  //       mode: LaunchMode.inAppWebView, // ✅ opens inside the app
  //       webViewConfiguration: const WebViewConfiguration(
  //         enableJavaScript: true,
  //         enableDomStorage: true,
  //       ),
  //     );
  //   } else {
  //     debugPrint("❌ Could not launch $url");
  //   }
  // }
  void _openLink(String url) async {
    final uri = Uri.parse(url);
    final isExternal = url.contains('facebook.com') || url.contains('instagram.com');

    await launchUrl(
      uri,
      mode:
      // isExternal
      //     ? LaunchMode.externalApplication
      //     :
      LaunchMode.inAppWebView,
    );
  }



  @override
  Widget build(BuildContext context) {
    if (_socialLinks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _socialLinks.map((social) {
          return GestureDetector(
            onTap: () => _openLink(social['link']),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.network(
                social['icon'],
                width: 35,
                height: 35,
                fit: BoxFit.contain,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
