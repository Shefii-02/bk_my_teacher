import 'package:BookMyTeacher/presentation/teachers/quick_action/spend_time_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/spend_time_card_provider.dart';

class SpendTimeCard extends ConsumerWidget {
  const SpendTimeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(spendTimeCardProvider);

    return asyncData.when(
      loading: () => _buildContainer(
        context,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _buildContainer(
        context,
        child: Center(child: Text("Error: $e")),
      ),
      data: (items) {
        return _buildContainer(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER ROW
              Row(
                children: [
                  const Text(
                    "Spend Time",
                    style: TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => SpendTimeSheet(),
                      );
                    },
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),

              /// API BASED THREE ITEMS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items
                    .map(
                      (e) => _SpendItem(
                    icon: e.icon,
                    title: e.title,
                    time: e.time,
                  ),
                )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContainer(BuildContext context, {required Widget child}) {
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
      child: child,
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