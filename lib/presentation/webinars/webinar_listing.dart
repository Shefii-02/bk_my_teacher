import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/launch_status_service.dart';
import '../../services/webinar_service.dart';
import '../components/webinar_card.dart';

class WebinarListPage extends ConsumerWidget {
  const WebinarListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: LaunchStatusService.getUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final accType = snapshot.data!;
        final webinarsAsync = ref.watch(webinarListProvider(accType));

        return webinarsAsync.when(
          data: (webinars) {
            if (webinars.isEmpty)
              return const Center(child: Text("No webinars found."));
            return Column(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: webinars.length,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return WebinarCard(webinar: webinars[index]);
                  },
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
        );
      },
    );
  }
}
