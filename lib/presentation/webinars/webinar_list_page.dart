// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';
// import 'webinar_detail_page.dart';
//
// class WebinarListPage extends StatefulWidget {
//   final ApiService api;
//   const WebinarListPage({super.key, required this.api});
//
//   @override
//   State<WebinarListPage> createState() => _WebinarListPageState();
// }
//
// class _WebinarListPageState extends State<WebinarListPage> {
//   List<dynamic> webinars = [];
//   bool loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     load();
//   }
//
//   Future load() async {
//     setState(() => loading = true);
//     try {
//       final w = await widget.api.fetchWebinars();
//       setState(() => webinars = w);
//     } catch (e) {
//       debugPrint("Error loading webinars: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to load webinars')),
//         );
//       }
//     } finally {
//       setState(() => loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Webinars')),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         itemCount: webinars.length,
//         itemBuilder: (ctx, i) {
//           final item = webinars[i];
//           return ListTile(
//             title: Text(item['title'] ?? 'No title'),
//             subtitle: Text(item['description'] ?? ''),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) =>
//                       WebinarDetailPage(api: widget.api, item: item),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: load,
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }
