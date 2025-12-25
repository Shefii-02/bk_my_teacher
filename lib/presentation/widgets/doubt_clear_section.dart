import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DoubtClearSection extends StatefulWidget {
  final String classId;
  final String type;

  const DoubtClearSection({
    super.key,
    required this.classId,
    required this.type,
  });

  @override
  State<DoubtClearSection> createState() => _DoubtClearSectionState();
}

class _DoubtClearSectionState extends State<DoubtClearSection> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _doubts = [];
  bool _isSubmitting = false;

  /// ✅ Make function async
  Future<void> _submitDoubt() async {
    bool success = false;

    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final type = widget.type;
    if (widget.type == 'course') {
      success = await ApiService().courseClassDoubtSubmit(
        classId: widget.classId,
        doubt: text,
      );
    } else if (widget.type == 'webinar') {
      print(widget.type);
      success = await ApiService().webinarClassDoubtSubmit(
        classId: widget.classId,
        doubt: text,
      );
    } else if (widget.type == 'workshop') {
      success = await ApiService().workshopClassDoubtSubmit(
        classId: widget.classId,
        doubt: text,
      );
    }

    // if (success) {
      setState(() {
        _doubts.insert(0, text);
        _controller.clear();
        _isSubmitting = false;
      });

    _controller.clear(); FocusScope.of(context).unfocus();

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Doubt submitted successfully')),
      // );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Failed to submit doubt')),
    //   );
    // }

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

        /// Input Field
        TextField(
          controller: _controller,
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Enter your doubt",
            suffixIcon: _isSubmitting
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitDoubt,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (_doubts.isNotEmpty)
          const Text(
            "Your Doubts",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

        const SizedBox(height: 8),

        /// Doubt List
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
