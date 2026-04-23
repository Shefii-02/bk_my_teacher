// ─── poll_tab.dart ────────────────────────────────────────────────────────────

import 'package:BookMyTeacher/presentation/record_section/record_screen_models.dart';
import 'package:flutter/material.dart';

// ── PollTab ───────────────────────────────────────────────────────────────────

class PollTab extends StatelessWidget {
  final Poll? poll;
  final bool loading;
  final ValueChanged<String> onVote;
  final VoidCallback onRefresh;

  const PollTab({
    super.key,
    required this.poll,
    required this.loading,
    required this.onVote,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: Color(0xFF6C63FF), strokeWidth: 2));
    }

    if (poll == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.poll_outlined,
                color: Colors.white12, size: 48),
            const SizedBox(height: 12),
            const Text('No active poll',
                style:
                TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded,
                  color: Color(0xFF6C63FF), size: 18),
              label: const Text('Refresh',
                  style: TextStyle(color: Color(0xFF6C63FF))),
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFF0F0F13),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.poll_rounded,
                          color: Color(0xFF6C63FF), size: 16),
                      SizedBox(width: 6),
                      Text('Live Poll',
                          style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    poll!.question,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${poll!.totalVotes} vote${poll!.totalVotes != 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Options
            ...poll!.options.map((opt) => PollOptionItem(
              option: opt,
              total: poll!.totalVotes,
              voted: poll!.myVoteId != null,
              isMyVote: poll!.myVoteId == opt.id,
              onTap: () => onVote(opt.id),
            )),

            if (poll!.myVoteId != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.greenAccent, size: 14),
                    SizedBox(width: 6),
                    Text('Your vote has been recorded',
                        style: TextStyle(
                            color: Colors.greenAccent, fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── PollOptionItem ────────────────────────────────────────────────────────────

class PollOptionItem extends StatelessWidget {
  final PollOption option;
  final int total;
  final bool voted, isMyVote;
  final VoidCallback onTap;

  const PollOptionItem({
    super.key,
    required this.option,
    required this.total,
    required this.voted,
    required this.isMyVote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : option.votes / total;

    return GestureDetector(
      onTap: voted ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isMyVote
              ? const Color(0xFF6C63FF).withOpacity(0.18)
              : const Color(0xFF16161D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMyVote
                ? const Color(0xFF6C63FF).withOpacity(0.6)
                : Colors.white10,
            width: isMyVote ? 1.2 : 0.5,
          ),
        ),
        child: Stack(
          children: [
            if (voted)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: pct,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isMyVote
                          ? const Color(0xFF6C63FF).withOpacity(0.2)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isMyVote
                          ? const Color(0xFF6C63FF)
                          : Colors.white30,
                      width: 1.5,
                    ),
                    color: isMyVote
                        ? const Color(0xFF6C63FF)
                        : Colors.transparent,
                  ),
                  child: isMyVote
                      ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 11)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    option.text,
                    style: TextStyle(
                      color:
                      isMyVote ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight: isMyVote
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (voted) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isMyVote
                          ? const Color(0xFF6C63FF)
                          : Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}