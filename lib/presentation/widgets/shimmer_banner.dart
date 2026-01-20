import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BannerShimmer extends StatelessWidget {
  final double height;
  final double borderRadius;

  const BannerShimmer({
    super.key,
    this.height = 130,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.green[100]!,
      highlightColor: Colors.green[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        color: Colors.transparent,
      ),
    );
  }
}
