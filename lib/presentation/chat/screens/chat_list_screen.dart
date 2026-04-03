// // lib/screens/chat_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:timeago/timeago.dart' as timeago;
//
// import '../../../core/app_theme.dart';
// import '../../../model/conversation_model.dart';
// import '../../../model/user_model.dart';
// import '../../../services/chat_api_service.dart';
// import 'chat_screen.dart';
//
// class ChatListScreen extends StatefulWidget {
//   final UserModel currentUser;
//   const ChatListScreen({super.key, required this.currentUser});
//
//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }
//
// class _ChatListScreenState extends State<ChatListScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<ConversationModel> _all = [];
//   List<ConversationModel> _groups = [];
//   List<ConversationModel> _directs = [];
//   bool _loading = true;
//   String _search = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadConversations();
//   }
//
//   Future<void> _loadConversations() async {
//     print("_________");
//     setState(() => _loading = true);
//     try {
//       // final list = await ChatApiService().getConversations();
//       // setState(() {
//       //   _all = list;
//       //   _groups = list.where((c) => c.type == 'group').toList();
//       //   _directs = list.where((c) => c.type == 'direct').toList();
//       //   _loading = false;
//       // });
//     } catch (e) {
//       print(e);
//       setState(() => _loading = false);
//     }
//   }
//
//   List<ConversationModel> _filtered(List<ConversationModel> src) {
//     if (_search.isEmpty) return src;
//     return src
//         .where(
//           (c) => c.displayName.toLowerCase().contains(_search.toLowerCase()),
//         )
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.surface,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Chats',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//                 color: AppTheme.textPrimary,
//               ),
//             ),
//             // Text(widget.currentUser.role.toUpperCase(),
//             //     style: const TextStyle(fontSize: 11, color: AppTheme.primary,
//             //         fontWeight: FontWeight.w600, letterSpacing: 1)),
//           ],
//         ),
//         actions: [
//           // New chat button (admin can create group)
//
//           //   IconButton(
//           //     icon: Container(
//           //       padding: const EdgeInsets.all(6),
//           //       decoration: BoxDecoration(
//           //         color: AppTheme.primaryLight,
//           //         borderRadius: BorderRadius.circular(10),
//           //       ),
//           //       child: const Icon(Icons.group_add, color: AppTheme.primary, size: 20),
//           //     ),
//           //     onPressed: _showNewGroupDialog,
//           //   ),
//           // IconButton(
//           //   icon: Container(
//           //     padding: const EdgeInsets.all(6),
//           //     decoration: BoxDecoration(
//           //       color: AppTheme.primaryLight,
//           //       borderRadius: BorderRadius.circular(10),
//           //     ),
//           //     child: const Icon(Icons.edit_square, color: AppTheme.primary, size: 20),
//           //   ),
//           //   onPressed: () {},
//           // ),
//           const SizedBox(width: 8),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(48),
//           child: Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: AppTheme.primary,
//               unselectedLabelColor: AppTheme.textSecondary,
//               indicatorColor: AppTheme.primary,
//               indicatorSize: TabBarIndicatorSize.label,
//               tabs: [
//                 Tab(text: 'All (${_all.length})'),
//                 Tab(text: 'Groups (${_groups.length})'),
//                 Tab(text: 'Direct (${_directs.length})'),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // ── Search bar ─────────────────────────────────────
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//             child: TextField(
//               onChanged: (v) => setState(() => _search = v),
//               decoration: InputDecoration(
//                 hintText: 'Search conversations…',
//                 hintStyle: TextStyle(
//                   color: AppTheme.textSecondary,
//                   fontSize: 14,
//                 ),
//                 prefixIcon: const Icon(
//                   Icons.search,
//                   color: AppTheme.textSecondary,
//                   size: 20,
//                 ),
//                 filled: true,
//                 fillColor: AppTheme.surface,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//             ),
//           ),
//           const Divider(height: 1, color: AppTheme.divider),
//
//           // ── Tab views ──────────────────────────────────────
//           Expanded(
//             child: _loading
//                 ? _buildShimmer()
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildList(_filtered(_all)),
//                       _buildList(_filtered(_groups)),
//                       _buildList(_filtered(_directs)),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildList(List<ConversationModel> convs) {
//
//     if (convs.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.divider),
//             const SizedBox(height: 12),
//             Text(
//               'No conversations yet',
//               style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
//             ),
//           ],
//         ),
//       );
//     }
//     return RefreshIndicator(
//       onRefresh: _loadConversations,
//       color: AppTheme.primary,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         itemCount: convs.length,
//         separatorBuilder: (_, __) => const Padding(
//           padding: EdgeInsets.only(left: 88),
//           child: Divider(height: 1, color: AppTheme.divider),
//         ),
//         itemBuilder: (_, i) => _ConversationTile(
//           conv: convs[i],
//           currentUser: widget.currentUser,
//           onTap: () async {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ChatScreen(
//                   conversation: convs[i],
//                   currentUser: widget.currentUser,
//                 ),
//               ),
//             );
//             _loadConversations(); // refresh unread counts on return
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildShimmer() {
//     return ListView.builder(
//       itemCount: 8,
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemBuilder: (_, __) => const _ShimmerTile(),
//     );
//   }
//
//   void _showNewGroupDialog() {
//     final nameCtrl = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('New Group'),
//         content: TextField(
//           controller: nameCtrl,
//           decoration: const InputDecoration(hintText: 'Group name'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               // In a real app you'd pick members too
//               Navigator.pop(context);
//             },
//             child: const Text('Create'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Conversation Tile ────────────────────────────────────────
// class _ConversationTile extends StatelessWidget {
//   final ConversationModel conv;
//   final UserModel currentUser;
//   final VoidCallback onTap;
//   const _ConversationTile({
//     required this.conv,
//     required this.currentUser,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isGroup = conv.type == 'group';
//     final hasUnread = conv.unreadCount > 0;
//     final lastTime = conv.lastMessageTime != null
//         ? timeago.format(DateTime.parse(conv.lastMessageTime!))
//         : '';
//
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         child: Row(
//           children: [
//             // Avatar
//             Stack(
//               children: [
//                 _Avatar(
//                   name: conv.displayName,
//                   imageUrl: conv.displayAvatar,
//                   isGroup: isGroup,
//                   size: 52,
//                 ),
//                 if (!isGroup && conv.isOnline)
//                   Positioned(
//                     right: 2,
//                     bottom: 2,
//                     child: Container(
//                       width: 12,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         color: AppTheme.success,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white, width: 2),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(width: 12),
//
//             // Name + last message
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       // Role badge for direct
//                       if (!isGroup && conv.otherUserRole != null)
//                         _RoleBadge(role: conv.otherUserRole!),
//                       if (!isGroup && conv.otherUserRole != null)
//                         const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           conv.displayName,
//                           style: TextStyle(
//                             fontWeight: hasUnread
//                                 ? FontWeight.w700
//                                 : FontWeight.w600,
//                             fontSize: 15,
//                             color: AppTheme.textPrimary,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Text(
//                         lastTime,
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: hasUnread
//                               ? AppTheme.primary
//                               : AppTheme.textSecondary,
//                           fontWeight: hasUnread
//                               ? FontWeight.w600
//                               : FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 3),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _LastMessagePreview(
//                           type: conv.lastMessageType,
//                           content: conv.lastMessage,
//                           hasUnread: hasUnread,
//                         ),
//                       ),
//                       if (hasUnread)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 7,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppTheme.primary,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             conv.unreadCount > 99
//                                 ? '99+'
//                                 : '${conv.unreadCount}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _LastMessagePreview extends StatelessWidget {
//   final String? type;
//   final String? content;
//   final bool hasUnread;
//   const _LastMessagePreview({this.type, this.content, required this.hasUnread});
//
//   @override
//   Widget build(BuildContext context) {
//     IconData? icon;
//     String text;
//
//     switch (type) {
//       case 'voice':
//         icon = Icons.mic;
//         text = 'Voice message';
//         break;
//       case 'pdf':
//         icon = Icons.picture_as_pdf;
//         text = 'PDF document';
//         break;
//       case 'docx':
//         icon = Icons.description;
//         text = 'Word document';
//         break;
//       case 'image':
//         icon = Icons.image;
//         text = 'Photo';
//         break;
//       default:
//         text = content ?? '';
//     }
//
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (icon != null) ...[
//           Icon(
//             icon,
//             size: 14,
//             color: hasUnread ? AppTheme.primary : AppTheme.textSecondary,
//           ),
//           const SizedBox(width: 4),
//         ],
//         Flexible(
//           child: Text(
//             text,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontSize: 13,
//               color: hasUnread ? AppTheme.textPrimary : AppTheme.textSecondary,
//               fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _RoleBadge extends StatelessWidget {
//   final String role;
//   const _RoleBadge({required this.role});
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = {
//       'admin': [const Color(0xFFFFF3E0), const Color(0xFFF57C00)],
//       'teacher': [const Color(0xFFE8F5E9), const Color(0xFF388E3C)],
//       'student': [AppTheme.primaryLight, AppTheme.primary],
//     };
//     final c = colors[role] ?? [AppTheme.primaryLight, AppTheme.primary];
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: c[0],
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         role[0].toUpperCase() + role.substring(1),
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w700,
//           color: c[1],
//         ),
//       ),
//     );
//   }
// }
//
// // ── Avatar ───────────────────────────────────────────────────
// class _Avatar extends StatelessWidget {
//   final String name;
//   final String? imageUrl;
//   final bool isGroup;
//   final double size;
//   const _Avatar({
//     required this.name,
//     this.imageUrl,
//     this.isGroup = false,
//     this.size = 48,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final initials = isGroup
//         ? (name.isNotEmpty ? name[0].toUpperCase() : 'G')
//         : (name.split(' ').length >= 2
//               ? '${name.split(' ')[0][0]}${name.split(' ')[1][0]}'.toUpperCase()
//               : (name.isEmpty ? '?' : name[0].toUpperCase()));
//
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           colors: isGroup
//               ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
//               : [AppTheme.primary, AppTheme.accent],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: imageUrl != null
//           ? ClipOval(
//               child: Image.network(
//                 imageUrl!,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => _initials(initials),
//               ),
//             )
//           : _initials(initials),
//     );
//   }
//
//   Widget _initials(String text) => Center(
//     child: Text(
//       text,
//       style: TextStyle(
//         color: Colors.white,
//         fontSize: size * 0.35,
//         fontWeight: FontWeight.w700,
//       ),
//     ),
//   );
// }
//
// // ── Shimmer placeholder ──────────────────────────────────────
// class _ShimmerTile extends StatelessWidget {
//   const _ShimmerTile();
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Row(
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: AppTheme.divider,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 14,
//                   width: 120,
//                   decoration: BoxDecoration(
//                     color: AppTheme.divider,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Container(
//                   height: 12,
//                   width: 200,
//                   decoration: BoxDecoration(
//                     color: AppTheme.divider,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
