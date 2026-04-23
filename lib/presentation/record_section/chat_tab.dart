// ─── chat_tab.dart ────────────────────────────────────────────────────────────

import 'package:BookMyTeacher/presentation/record_section/record_screen_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


// ── _ChatTab ──────────────────────────────────────────────────────────────────

class ChatTab extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final TextEditingController chatCtrl;
  final bool connected;
  final VoidCallback onSend;

  const ChatTab({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.chatCtrl,
    required this.connected,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0F13),
      child: Column(
        children: [
          // connection status banner
          if (!connected)
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              color: Colors.red.shade900.withOpacity(0.6),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded,
                      color: Colors.redAccent, size: 13),
                  SizedBox(width: 6),
                  Text(
                    'Reconnecting to live chat...',
                    style:
                    TextStyle(color: Colors.redAccent, fontSize: 11),
                  ),
                ],
              ),
            ),

          // messages list
          Expanded(
            child: messages.isEmpty
                ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.white12, size: 40),
                  SizedBox(height: 10),
                  Text('No messages yet',
                      style: TextStyle(
                          color: Colors.white24, fontSize: 13)),
                ],
              ),
            )
                : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (_, i) =>
                  ChatBubble(message: messages[i]),
            ),
          ),

          // input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: Color(0xFF16161D),
              border: Border(
                  top: BorderSide(color: Colors.white10, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatCtrl,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: connected
                          ? 'Type a message...'
                          : 'Connecting...',
                      hintStyle: const TextStyle(
                          color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF22222C),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: connected ? onSend : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: connected
                          ? const Color(0xFF6C63FF)
                          : Colors.white12,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── ChatBubble ────────────────────────────────────────────────────────────────

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMe ? 40 : 0,
        right: isMe ? 0 : 40,
      ),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor:
              const Color(0xFF6C63FF).withOpacity(0.25),
              child: Text(
                message.avatarInitial,
                style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 2),
                    child: Text(
                      message.sender,
                      style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFF22222C),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('hh:mm a').format(message.time),
                  style: const TextStyle(
                      color: Colors.white24, fontSize: 9),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 6),
        ],
      ),
    );
  }
}