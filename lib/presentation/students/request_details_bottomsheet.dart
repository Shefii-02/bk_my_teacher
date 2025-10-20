import 'package:flutter/material.dart';

class RequestDetailsBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> requests;

  const RequestDetailsBottomSheet({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          const Text(
            "Requested Classes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (_, i) {
                final item = requests[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text(item['to']),
                    subtitle: Text("Date: ${item['requested_date']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item['status'],
                            style: TextStyle(
                                color: item['status'] == "Approved"
                                    ? Colors.green
                                    : Colors.orange)),
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye_outlined),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Request Details"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("To: ${item['to']}"),
                                    Text("Status: ${item['status']}"),
                                    Text("Notes: ${item['notes']}"),
                                    Text("Demo Class: ${item['demo_class']}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
