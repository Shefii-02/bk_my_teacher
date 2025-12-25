import 'package:flutter/material.dart';

import '../../core/constants/image_paths.dart';

class BodyBg extends StatelessWidget {
  const BodyBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(ImagePaths.appBg, fit: BoxFit.cover);
  }
}
