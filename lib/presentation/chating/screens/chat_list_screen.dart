// lib/screens/chat_list_screen.dart
import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:BookMyTeacher/core/constants/extensions.dart';
import 'package:BookMyTeacher/presentation/chating/services/chat_api.dart';
import 'package:BookMyTeacher/services/launch_status_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/app_theme.dart';
import '../../../core/constants/extensions.dart';
import '../models/conversation_model.dart';
import '../../../model/user_model.dart';
import '../../../services/chat_api_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String token;
  final int userId;
  const ChatListScreen({super.key, required this.token, required this.userId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ConversationModel> _unRead = [];
  List<ConversationModel> _groups = [];
  List<ConversationModel> _directs = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSafetyAlertOncePerDay(context);
    });
    _tabController = TabController(length: 3, vsync: this);
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    // If you want reset option (for testing or settings screen):
    // await prefs.remove('chat_alert_disabled');
    // await prefs.remove('chat_alert_date');
    setState(() => _loading = true);
    try {
      final list = await ChatApiService().getConversations(widget.token);

      setState(() {
        // _unRead = list;
        _unRead = list
            .where((c) => c.unreadCount > 0)
            .toList();
        _groups = list.where((c) => c.type == 'group').toList();
        _directs = list.where((c) => c.type == 'direct').toList();
        _loading = false;
      });
    } catch (e) {
      print(e);
      setState(() => _loading = false);
    }
  }

  List<ConversationModel> _filtered(List<ConversationModel> src) {
    if (_search.isEmpty) return src;
    return src
        .where(
          (c) => c.displayName.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chats',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            // Text(widget.currentUser.role.toUpperCase(),
            //     style: const TextStyle(fontSize: 11, color: AppTheme.primary,
            //         fontWeight: FontWeight.w600, letterSpacing: 1)),
          ],
        ),
        actions: [
          // New chat button (admin can create group)

          //   IconButton(
          //     icon: Container(
          //       padding: const EdgeInsets.all(6),
          //       decoration: BoxDecoration(
          //         color: AppTheme.primaryLight,
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       child: const Icon(Icons.group_add, color: AppTheme.primary, size: 20),
          //     ),
          //     onPressed: _showNewGroupDialog,
          //   ),
          // IconButton(
          //   icon: Container(
          //     padding: const EdgeInsets.all(6),
          //     decoration: BoxDecoration(
          //       color: AppTheme.primaryLight,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: const Icon(Icons.edit_square, color: AppTheme.primary, size: 20),
          //   ),
          //   onPressed: () {},
          // ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: 'Unread (${_unRead.length})'),
                Tab(text: 'Groups (${_groups.length})'),
                Tab(text: 'Direct (${_directs.length})'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          // ── Search bar ─────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search conversations…',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),

          // ── Tab views ──────────────────────────────────────
          Expanded(
            child: _loading
                ? _buildShimmer()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_filtered(_unRead)),
                      _buildList(_filtered(_groups)),
                      _buildList(_filtered(_directs)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<ConversationModel> convs) {
    if (convs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.divider),
            const SizedBox(height: 12),
            Text(
              'No conversations yet',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: AppTheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: convs.length,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(left: 88),
          child: Divider(height: 1, color: AppTheme.divider),
        ),
        itemBuilder: (_, i) => _ConversationTile(
          conv: convs[i],
          token: widget.token,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  conversation: convs[i],
                  token: widget.token,
                  userId: widget.userId,
                ),
              ),
            );
            _loadConversations(); // refresh unread counts on return
          },
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (_, __) => const _ShimmerTile(),
    );
  }

  void _showNewGroupDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Group'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(hintText: 'Group name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // In a real app you'd pick members too
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> showSafetyAlertOncePerDay(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Check if user disabled alert permanently
    final isDisabled = prefs.getBool('chat_alert_disabled') ?? false;
    if (isDisabled) return;

    // ✅ Check daily logic
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastShownDate = prefs.getString('chat_alert_date');

    if (lastShownDate == today) return;

    bool dontShowAgain = false;

    // ✅ Show dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("⚠️ Safety Alert"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "For app verification, never share your login details, OTP, or personal information with anyone.",
                  ),
                  const SizedBox(height: 12),

                  // ✅ Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: dontShowAgain,
                        onChanged: (val) {
                          setState(() {
                            dontShowAgain = val ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "Don't show again",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    // ✅ Save today's date
                    await prefs.setString('chat_alert_date', today);

                    // ✅ Save permanent disable
                    if (dontShowAgain) {
                      await prefs.setBool('chat_alert_disabled', true);
                    }
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Conversation Tile ────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final ConversationModel conv;
  final String token;
  final VoidCallback onTap;
  const _ConversationTile({
    required this.conv,
    required this.token,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGroup = conv.type == 'group';
    final hasUnread = conv.unreadCount > 0;
    final lastTime = conv.lastMessageTime != null
        ? timeago.format(DateTime.parse(conv.lastMessageTime!))
        : '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                clipBehavior: Clip.none,
                children: [

                  // Main Avatar / Group Badge
                  if (conv.typeConversation == 'Group')
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4F46E5),
                            Color(0xFF6366F1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            offset: Offset(0, 3),
                            color: Colors.black12,
                          )
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            color: Colors.white,
                            size: 26,
                          ),

                          // Small group indicator
                          Positioned(
                            right: 3,
                            bottom: 3,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  else
                    _Avatar(
                      name: conv.conversationName,
                      imageUrl: conv.displayAvatar,
                      isGroup: isGroup,
                      size: 52,
                    ),

                  // Online indicator for 1-to-1 only
                  if (!isGroup && conv.isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.black12,
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Role badge for direct
                      if (!isGroup && conv.otherUserRole != null)
                        _RoleBadge(role: conv.otherUserRole!),
                      if (!isGroup && conv.otherUserRole != null)
                        const SizedBox(width: 6),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              limitString((conv.conversationName.capitalize()),15),
                              style: TextStyle(
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 15,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                            conv.roleName.isNotEmpty ? ' (${conv.roleName.capitalize()})' : '',
                              style: TextStyle(
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 9,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        lastTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: hasUnread
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: _LastMessagePreview(
                          type: conv.lastMessageType,
                          content: conv.lastMessage,
                          hasUnread: hasUnread,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conv.unreadCount > 99
                                ? '99+'
                                : '${conv.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastMessagePreview extends StatelessWidget {
  final String? type;
  final String? content;
  final bool hasUnread;
  const _LastMessagePreview({this.type, this.content, required this.hasUnread});

  @override
  Widget build(BuildContext context) {
    IconData? icon;
    String text;

    switch (type) {
      case 'voice':
        icon = Icons.mic;
        text = 'Voice message';
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf;
        text = 'PDF document';
        break;
      case 'docx':
        icon = Icons.description;
        text = 'Word document';
        break;
      case 'image':
        icon = Icons.image;
        text = 'Photo';
        break;
      default:
        text = content ?? '';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 14,
            color: hasUnread ? AppTheme.primary : AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: hasUnread ? AppTheme.textPrimary : AppTheme.textSecondary,
              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'company': [const Color(0xFFFFF3E0), const Color(0xFFF57C00)],
      'teacher': [const Color(0xFFE8F5E9), const Color(0xFF388E3C)],
      'student': [AppTheme.primaryLight, AppTheme.primary],
    };
    final c = colors[role] ?? [AppTheme.primaryLight, AppTheme.primary];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c[0],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role[0].toUpperCase() + role.substring(1),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: c[1],
        ),
      ),
    );
  }
}

// ── Avatar ───────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isGroup;
  final double size;
  const _Avatar({
    required this.name,
    this.imageUrl,
    this.isGroup = false,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    final initials = isGroup
        ? (name.isNotEmpty ? name[0].toUpperCase() : 'G')
        : (parts.length >= 2
              ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
              : (parts.isEmpty ? '?' : parts[0][0].toUpperCase()));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isGroup
              ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
              : [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: imageUrl != null
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initials(initials),
              ),
            )
          : _initials(initials),
    );
  }

  Widget _initials(String text) => Center(
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.35,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// ── Shimmer placeholder ──────────────────────────────────────
class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(4),
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
