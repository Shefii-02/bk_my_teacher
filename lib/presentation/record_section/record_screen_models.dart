// ─── models.dart ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── ChatMessage ───────────────────────────────────────────────────────────────

class ChatMessage {
  final String id;
  final String sender;
  final String avatarInitial;
  final String text;
  final DateTime time;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.avatarInitial,
    required this.text,
    required this.time,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j, {bool isMe = false}) =>
      ChatMessage(
        id: j['id']?.toString() ?? UniqueKey().toString(),
        sender: j['sender'] ?? 'Unknown',
        avatarInitial: (j['sender'] ?? 'U')[0].toUpperCase(),
        text: j['message'] ?? '',
        time: j['timestamp'] != null
            ? DateTime.tryParse(j['timestamp']) ?? DateTime.now()
            : DateTime.now(),
        isMe: isMe,
      );
}

// ── PollOption ────────────────────────────────────────────────────────────────

class PollOption {
  final String id;
  final String text;
  int votes;

  PollOption({required this.id, required this.text, this.votes = 0});

  factory PollOption.fromJson(Map<String, dynamic> j) => PollOption(
    id: j['id']?.toString() ?? '',
    text: j['text'] ?? '',
    votes: (j['votes'] as num?)?.toInt() ?? 0,
  );
}

// ── Poll ──────────────────────────────────────────────────────────────────────

class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  int totalVotes;
  String? myVoteId;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    this.totalVotes = 0,
    this.myVoteId,
  });

  factory Poll.fromJson(Map<String, dynamic> j) {
    final options = (j['options'] as List<dynamic>? ?? [])
        .map((o) => PollOption.fromJson(o))
        .toList();
    return Poll(
      id: j['id']?.toString() ?? '',
      question: j['question'] ?? '',
      options: options,
      totalVotes: options.fold(0, (s, o) => s + o.votes),
    );
  }
}