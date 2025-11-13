import 'package:BookMyTeacher/services/api_service.dart';
import 'package:flutter/material.dart';
import '../../model/class_requests.dart';

class RequestsBottomSheet extends StatefulWidget {
  const RequestsBottomSheet({super.key});

  @override
  State<RequestsBottomSheet> createState() => _RequestsBottomSheetState();
}

class _RequestsBottomSheetState extends State<RequestsBottomSheet> {
  bool loading = true;
  List<ClassRequest> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      setState(() => loading = true);

      final List<dynamic> response = await ApiService().fetchClassRequests();

      setState(() {
        requests = response.map((e) => ClassRequest.fromJson(e)).toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching requests: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 🔹 Header Section with Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // spacing for symmetry
              const Text(
                "Requested Classes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),

          // 🔹 Body Section
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : requests.isEmpty
                ? const Center(child: Text("No class requests found"))
                : RefreshIndicator(
              onRefresh: fetchRequests,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _statusColor(req.status),
                        child: const Icon(Icons.school,
                            color: Colors.white, size: 20),
                      ),
                      title: Text(
                        req.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding:
                        const EdgeInsets.only(top: 4.0, bottom: 6),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${req.grade} • ${req.board}\n${req.subject}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            _buildStatusBadge(req.status),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye_rounded,
                          color: Colors.teal,
                        ),
                        onPressed: () => _showDetails(context, req),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 Status Color Mapping
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'scheduled':
        return Colors.green;
      case 'joined':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      case 'cancelled':
        return Colors.redAccent;
      case 'followed up':
        return Colors.blue;
      default:
        return Colors.orangeAccent;
    }
  }

  // 🎯 Status Badge
  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  // 🧾 Detail Dialog
  void _showDetails(BuildContext context, ClassRequest req) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Close Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      req.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow("Grade", req.grade),
                      _buildDetailRow("Board", req.board),
                      _buildDetailRow("Subject", req.subject),
                      _buildDetailRow("Status", req.status),
                      _buildDetailRow("Note", req.note),
                      _buildDetailRow("Requested On", req.createdAt),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📋 Detail Row Builder
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
