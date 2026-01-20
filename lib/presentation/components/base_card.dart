import 'package:BookMyTeacher/core/constants/extensions.dart';
import 'package:BookMyTeacher/presentation/components/shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:io' show Platform;

class BaseCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final String duration;
  final String level;
  final String badge;
  final dynamic actualPrice;
  final dynamic netPrice;



  const BaseCard({super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
    required this.badge,
    this.actualPrice,
    this.netPrice
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            if(badge != '')
            Align(
              alignment: Alignment.topRight,
              child: Text(badge.capitalize(),style: TextStyle(color: Colors.green,decoration: TextDecoration.underline))
            ),
            SizedBox(width: 20),
            Row(
              children: [
                if(image != '')
                ShimmerImage(
                  imageUrl: image ?? '',
                  width: 50,
                  height: 50,
                  borderRadius: 3,
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 200,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Html(data: description, style: {
              "body": Style(
                fontSize: FontSize(13),
                lineHeight: LineHeight(1),
                color: Colors.grey[700],
                maxLines: 1),}
            ),
            // Text(
            //   description,
            //   maxLines: 2,
            //   overflow: TextOverflow.ellipsis,
            //   style: TextStyle(
            //     fontSize: 13,
            //     color: Colors.grey[700],
            //   ),
            // ),
            if(Platform.isAndroid)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("⏳ $duration", style: const TextStyle(fontSize: 12)),
                // Text("🎯 $level", style: const TextStyle(fontSize: 12)),
                priceView(
                  actualPrice: actualPrice,
                  netPrice:  netPrice,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


Widget priceView({
  required dynamic actualPrice,
  required dynamic netPrice,
}) {
  if (netPrice == null) return const SizedBox.shrink();

  final actual = double.tryParse(actualPrice.toString());
  final net = double.tryParse(netPrice.toString());

  if (actual == null || net == null) {
    return const SizedBox.shrink();
  }

  // 🎯 If discounted
  if (actual > net) {
    return Row(
      children: [
        Text(
          "₹${actual.toStringAsFixed(0)}",
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.red,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "₹${net.toStringAsFixed(0)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  // 🎯 No discount
  return Text(
    "₹${net.toStringAsFixed(0)}",
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.green,
    ),
  );
}
