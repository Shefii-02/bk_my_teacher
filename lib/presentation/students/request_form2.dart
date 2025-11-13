// import 'package:flutter/material.dart';
// import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
// import '../../services/api_service.dart';
//
// class RequestForm extends StatefulWidget {
//   const RequestForm({super.key});
//
//   @override
//   State<RequestForm> createState() => _RequestFormState();
// }
//
// class _RequestFormState extends State<RequestForm> {
//   final TextEditingController fromCtrl = TextEditingController();
//   final TextEditingController noteCtrl = TextEditingController();
//
//   // 🔹 For “Other” manual entries
//   final TextEditingController otherGradeCtrl = TextEditingController();
//   final TextEditingController otherBoardCtrl = TextEditingController();
//   final TextEditingController otherSubjectCtrl = TextEditingController();
//
//   List<String> grades = [];
//   List<String> boards = [];
//   List<String> subjects = [];
//
//   List<String> selectedGrades = [];
//   List<String> selectedBoards = [];
//   List<String> selectedSubjects = [];
//
//   bool _loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   // 🔹 Load dropdown data from API
//   Future<void> _loadData() async {
//     final api = ApiService();
//     final results = await Future.wait([
//       api.fetchGrades(),
//       api.fetchBoards(),
//       api.fetchSubjects(),
//     ]);
//
//     setState(() {
//       grades = [...results[0], "Other"];
//       boards = [...results[1], "Other"];
//       subjects = [...results[2], "Other"];
//       _loading = false;
//     });
//   }
//
//   // 🔹 Submit form data
//   Future<void> _submit() async {
//     if (fromCtrl.text.isEmpty ||
//         (selectedGrades.isEmpty && otherGradeCtrl.text.isEmpty) ||
//         (selectedBoards.isEmpty && otherBoardCtrl.text.isEmpty) ||
//         (selectedSubjects.isEmpty && otherSubjectCtrl.text.isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all required fields")),
//       );
//       return;
//     }
//
//     final formData = {
//       'from': fromCtrl.text,
//       'grades': selectedGrades.contains('Other')
//           ? [otherGradeCtrl.text]
//           : selectedGrades,
//       'boards': selectedBoards.contains('Other')
//           ? [otherBoardCtrl.text]
//           : selectedBoards,
//       'subjects': selectedSubjects.contains('Other')
//           ? [otherSubjectCtrl.text]
//           : selectedSubjects,
//       'note': noteCtrl.text,
//     };
//
//     final res = await ApiService().submitRequestForm(formData);
//
//     if (res != null && res['status'] == true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(res['message'] ?? 'Request submitted!')),
//       );
//       fromCtrl.clear();
//       noteCtrl.clear();
//       otherGradeCtrl.clear();
//       otherBoardCtrl.clear();
//       otherSubjectCtrl.clear();
//       setState(() {
//         selectedGrades.clear();
//         selectedBoards.clear();
//         selectedSubjects.clear();
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(res?['message'] ?? 'Submission failed'),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return Column(
//       children: [
//         const SizedBox(height: 30),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 14.0),
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0x52B0FFDF),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.green.withOpacity(0.2),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Request a Class/Course",
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w900,
//                         color: Colors.black,
//                       ),
//                     ),
//                     TextButton.icon(
//                       onPressed: () => _showRequestsBottomSheet(context),
//                       icon: const Icon(Icons.history),
//                       label: const Text(
//                         "View Requested Classes",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w300,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Row 1: From + Grades
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildField(
//                         controller: fromCtrl,
//                         label: "You are from?",
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildFakeDropdown(
//                         label: "Grades",
//                         values: grades,
//                         selected: selectedGrades,
//                         onSelect: (v) => setState(() => selectedGrades = v),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 if (selectedGrades.contains("Other")) ...[
//                   const SizedBox(height: 12),
//                   _buildField(
//                     controller: otherGradeCtrl,
//                     label: "Enter your Grade manually",
//                   ),
//                 ],
//
//                 const SizedBox(height: 16),
//
//                 // Row 2: Board + Subjects
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildFakeDropdown(
//                         label: "Board / Syllabus",
//                         values: boards,
//                         selected: selectedBoards,
//                         onSelect: (v) => setState(() => selectedBoards = v),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildFakeDropdown(
//                         label: "Subjects",
//                         values: subjects,
//                         selected: selectedSubjects,
//                         onSelect: (v) => setState(() => selectedSubjects = v),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 if (selectedBoards.contains("Other")) ...[
//                   const SizedBox(height: 12),
//                   _buildField(
//                     controller: otherBoardCtrl,
//                     label: "Enter your Board/Syllabus manually",
//                   ),
//                 ],
//
//                 if (selectedSubjects.contains("Other")) ...[
//                   const SizedBox(height: 12),
//                   _buildField(
//                     controller: otherSubjectCtrl,
//                     label: "Enter your Subject manually",
//                   ),
//                 ],
//
//                 const SizedBox(height: 16),
//
//                 _buildField(
//                   controller: noteCtrl,
//                   label: "Do you want to tell me something?",
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 28),
//
//                 Center(
//                   child: NeoPopTiltedButton(
//                     isFloating: true,
//                     onTapUp: _submit,
//                     decoration: const NeoPopTiltedButtonDecoration(
//                       color: Color(0xFF70E183),
//                       plunkColor: Color(0xFFE8F9E8),
//                       shadowColor: Color(0xFF2A3B2A),
//                       showShimmer: true,
//                     ),
//                     child: const Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 70.0,
//                         vertical: 15,
//                       ),
//                       child: Text(
//                         'Submit Request',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 40),
//       ],
//     );
//   }
//
//   // ---------- Input Field ----------
//   Widget _buildField({
//     required TextEditingController controller,
//     required String label,
//     int maxLines = 1,
//   }) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black87, fontSize: 12),
//         filled: true,
//         fillColor: Colors.green.shade50,
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.green.shade100),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(9),
//           borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
//         ),
//       ),
//     );
//   }
//
//   // ---------- Multi-select Dropdown ----------
//   Widget _buildFakeDropdown({
//     required String label,
//     required List<String> values,
//     required List<String> selected,
//     required Function(List<String>) onSelect,
//   }) {
//     return InkWell(
//       onTap: () {
//         showModalBottomSheet(
//           context: context,
//           backgroundColor: Colors.white,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           builder: (context) {
//             List<String> temp = List.from(selected);
//             return StatefulBuilder(
//               builder: (context, setStateModal) => Column(
//                 children: [
//                   const SizedBox(height: 12),
//                   Text(label, style: const TextStyle(fontSize: 16)),
//                   const Divider(),
//                   Expanded(
//                     child: ListView(
//                       children: values.map((v) {
//                         final isSelected = temp.contains(v);
//                         return CheckboxListTile(
//                           title: Text(v),
//                           value: isSelected,
//                           onChanged: (val) {
//                             setStateModal(() {
//                               if (val == true) {
//                                 temp.add(v);
//                               } else {
//                                 temp.remove(v);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       onSelect(temp);
//                       Navigator.pop(context);
//                     },
//                     child: const Text("Select"),
//                   ),
//                   const SizedBox(height: 12),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//       child: Container(
//         padding:
//         const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
//         decoration: BoxDecoration(
//           color: Colors.green.shade50,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.green.shade100),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               selected.isEmpty ? label : selected.join(", "),
//               style: TextStyle(
//                 color: selected.isEmpty ? Colors.black54 : Colors.black87,
//               ),
//             ),
//             const Icon(Icons.arrow_drop_down),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   void _showRequestsBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => const SizedBox(
//         height: 300,
//         child: Center(child: Text("Requested Classes List Here")),
//       ),
//     );
//   }
// }
