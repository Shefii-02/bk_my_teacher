import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/enums/app_config.dart';
import '../../presentation/teachers/dashboard_home.dart';
import '../../providers/user_provider.dart'; // for StepData, StepStatus

// ================= Account Message Card =================
class AccountMessageCard extends ConsumerWidget {
  final String accountMsg;
  final List<StepData> steps;

  const AccountMessageCard({
    super.key,
    required this.accountMsg,
    required this.steps,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    if (accountMsg.isEmpty) return const SizedBox();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Application Progress",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomVerticalStepper(steps: steps),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Colors.blueAccent),
            SizedBox(
              width: 280,
              child: Text(
                accountMsg,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                  height: 1.25,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

// ================= Custom Vertical Stepper =================
class CustomVerticalStepper extends ConsumerWidget {
  final List<StepData> steps;

  const CustomVerticalStepper({super.key, required this.steps});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (teacherData) {
        return Column(
          children: List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;

            return GestureDetector(
              onTap: step.allow
                  ? () {
                      Navigator.pop(context);
                      context.go(step.route);
                    }
                  : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: step.status == StepStatus.completed
                              ? Colors.green
                              : step.status == StepStatus.inProgress
                              ? Colors.white
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: step.status == StepStatus.inProgress
                                ? Colors.grey
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 50,
                          color: step.status == StepStatus.completed
                              ? Colors.green
                              : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 4,
                            children: [
                              Text(
                                step.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: step.allow
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                              if (step.allow)
                                Icon(
                                  Icons.edit_rounded,
                                  color: step.status == StepStatus.completed
                                      ? Colors.green
                                      : step.status == StepStatus.inProgress
                                      ? Colors.blue
                                      : Colors.grey,
                                  size: 14,
                                ),
                            ],
                          ),
                          if (step.subtitle != null)
                            SizedBox(
                              width: 300,
                              child: Text(
                                step.subtitle!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: step.status == StepStatus.completed
                                      ? Colors.green
                                      : step.status == StepStatus.inProgress
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 5,
                                softWrap: false,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text("Error: $err"),
    );
  }
}
