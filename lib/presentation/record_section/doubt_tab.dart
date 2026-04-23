// ─── doubt_tab.dart ───────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class DoubtTab extends StatelessWidget {
  final TextEditingController ctrl;
  final List<String> doubts;
  final bool submitting;
  final VoidCallback onSubmit;

  const DoubtTab({
    super.key,
    required this.ctrl,
    required this.doubts,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0F13),
      child: Column(
        children: [
          // Input box
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF16161D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🤔  Ask a Doubt',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ctrl,
                  maxLines: 3,
                  minLines: 2,
                  style:
                  const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Describe your doubt clearly...',
                    hintStyle: const TextStyle(
                        color: Colors.white30, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF22222C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: submitting ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: submitting
                        ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded,
                        size: 16, color: Colors.white),
                    label: Text(
                      submitting ? 'Submitting...' : 'Submit Doubt',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Previous doubts list
          if (doubts.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Doubts',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 12),
                itemCount: doubts.length,
                itemBuilder: (_, i) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white10, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.help_outline_rounded,
                          color: Color(0xFF6C63FF), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(doubts[i],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13)),
                      ),
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white24, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.quiz_outlined,
                        color: Colors.white12, size: 40),
                    SizedBox(height: 10),
                    Text('No doubts submitted yet',
                        style: TextStyle(
                            color: Colors.white24, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}