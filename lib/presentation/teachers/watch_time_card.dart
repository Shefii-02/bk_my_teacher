import 'package:flutter/material.dart';

class WatchTimeCard extends StatelessWidget {
  const WatchTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(1, 0),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Watch Time",
                style: TextStyle(
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.black.withOpacity(0.6)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _SpendItem(
                icon: "assets/images/icons/chart-4.png",
                title: "Individual Class’s",
                time: "30.4 hr",
              ),
              _SpendItem(
                icon: "assets/images/icons/chart-5.png",
                title: "Own Course Class’s",
                time: "30.4 hr",
              ),
              _SpendItem(
                icon: "assets/images/icons/chart-6.png",
                title: "Youtube Class’s",
                time: "30.4 hr",
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SpendItem extends StatelessWidget {
  final String icon;
  final String title;
  final String time;

  const _SpendItem({
    required this.icon,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // you can navigate to details page here
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, width: 28, height: 28),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 👈 makes title start from left
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start, // 👈 aligns title text to start
              ),
              const SizedBox(height: 3),
              Align(
                alignment: Alignment.center, // 👈 centers only the time text
                child: Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )


        ],
      ),
    );
  }
}