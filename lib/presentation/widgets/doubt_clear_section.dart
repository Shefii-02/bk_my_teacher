import 'package:flutter/material.dart';

class DoubtClearSection extends StatefulWidget {
  const DoubtClearSection({super.key});

  @override
  State<DoubtClearSection> createState() => _DoubtClearSectionState();
}

class _DoubtClearSectionState extends State<DoubtClearSection> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _doubts = [];

  void _submitDoubt() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _doubts.add(text);
      });
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Doubt Clearing Section",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Enter your doubt",
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitDoubt,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Your Doubts:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._doubts.map(
              (d) => Card(
            child: ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.blue),
              title: Text(d),
            ),
          ),
        ),
      ],
    );
  }
}
