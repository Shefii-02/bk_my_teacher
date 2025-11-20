// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class BookingBottomSheet extends StatefulWidget {
//   final Map<String, dynamic> teacher;
//   final Map<String, dynamic> pricing;
//   const BookingBottomSheet({super.key, required this.teacher, required this.pricing});
//
//   @override
//   State<BookingBottomSheet> createState() => _BookingBottomSheetState();
// }
//
// class _BookingBottomSheetState extends State<BookingBottomSheet> {
//   // Parsed lists
//   late final List<String> subjectList;
//   late final List<String> courseList;
//
//   // Selection state
//   String pickMode = "subject"; // 'subject' or 'course'
//   List<String> selectedItems = [];
//   String selectedClassType = 'Individual'; // 'Individual', 'Common', 'Crash'
//
//   // Date/time
//   DateTime? startDate;
//   String selectedSlot = "Morning";
//   final List<String> slots = ["Morning", "Afternoon", "Evening", "Night"];
//
//   // Hours & days
//   double selectedHours = 1;
//   int numberOfDays = 1;
//
//   // Pricing option
//   String pricingOption = "calculate"; // calculate | talk
//   double totalPrice = 0;
//   double selectedRatePerHour = 0;
//
//   // Notes
//   final TextEditingController notesController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     subjectList = _asStringList(widget.teacher['subjects']);
//     courseList = _asStringList(widget.teacher['courses']);
//
//     // Initialize price & rate
//     totalPrice = _calculatePrice(selectedHours, widget.pricing);
//     selectedRatePerHour = _rateForHours(selectedHours, widget.pricing);
//   }
//
//   @override
//   void dispose() {
//     notesController.dispose();
//     super.dispose();
//   }
//
//   // Helper to accept List or comma-separated string
//   List<String> _asStringList(dynamic value) {
//     if (value == null) return [];
//     if (value is List) {
//       return value.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).cast<String>().toList();
//     }
//     if (value is String) {
//       return value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
//     }
//     return [];
//   }
//
//   // Determine per-hour rate based on hours
//   double _rateForHours(double hours, Map<String, dynamic> pricing) {
//     try {
//       if (hours <= 10) {
//         return double.parse(pricing['below_10'].toString());
//       } else if (hours <= 30) {
//         return double.parse(pricing['10_to_30'].toString());
//       } else {
//         return double.parse(pricing['above_30'].toString());
//       }
//     } catch (_) {
//       return 0;
//     }
//   }
//
//   // Calculate total price
//   double _calculatePrice(double hours, Map<String, dynamic> pricing) {
//     final rate = _rateForHours(hours, pricing);
//     return rate * hours;
//   }
//
//   // Small formatter
//   String _fmtCurrency(double val) {
//     if (val % 1 == 0) {
//       return val.toStringAsFixed(0);
//     } else {
//       return val.toStringAsFixed(2);
//     }
//   }
//
//   // Validation and submit (you should call your API inside here)
//   void _onBookNow() {
//     // Basic validation
//     if (selectedItems.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one subject/course')));
//       return;
//     }
//     if (startDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please choose the class starting date')));
//       return;
//     }
//     if (pricingOption == "calculate" && selectedHours <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select hours')));
//       return;
//     }
//
//     // Build payload
//     final payload = {
//       'teacher_id': widget.teacher['id'],
//       'selected_type': pickMode,
//       'selected_items': selectedItems,
//       'class_type': selectedClassType.toLowerCase(),
//       'start_date': DateFormat('yyyy-MM-dd').format(startDate!),
//       'time_slot': selectedSlot,
//       'hours': pricingOption == "calculate" ? selectedHours.round() : null,
//       'hours_rate': pricingOption == "calculate" ? selectedRatePerHour : null,
//       'total_price': pricingOption == "calculate" ? totalPrice : null,
//       'number_of_days': pricingOption == "calculate" ? numberOfDays : null,
//       'pricing_option': pricingOption,
//       'notes': notesController.text.trim(),
//     };
//
//     // TODO: call your API with payload (ApiService().bookClass(payload) etc.)
//     // For now just pop with result
//     Navigator.of(context).pop(payload);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final pricing = widget.pricing;
//     final rateBelow10 = double.tryParse(pricing['below_10'].toString()) ?? 0;
//     final rate10to30 = double.tryParse(pricing['10_to_30'].toString()) ?? 0;
//     final rateAbove30 = double.tryParse(pricing['above_30'].toString()) ?? 0;
//
//     // current highlighted index for rates card
//     int highlighted = selectedHours <= 10 ? 0 : (selectedHours <= 30 ? 1 : 2);
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.only(left: 20, right: 20, top: 18, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Center(
//             child: Container(
//               height: 5,
//               width: 70,
//               decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3)),
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Center(
//             child: Text('📘 Book a Class', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           ),
//           const SizedBox(height: 18),
//
//           // 1) Toggle Subject / Course
//           _sectionTitle("Pick Subject / Course"),
//           Row(
//             children: [
//               ChoiceChip(
//                 label: const Text('Subjects'),
//                 selected: pickMode == 'subject',
//                 selectedColor: Colors.blue.shade50,
//                 onSelected: (_) => setState(() {
//                   pickMode = 'subject';
//                   selectedItems.clear();
//                 }),
//               ),
//               const SizedBox(width: 8),
//               ChoiceChip(
//                 label: const Text('Courses'),
//                 selected: pickMode == 'course',
//                 selectedColor: Colors.blue.shade50,
//                 onSelected: (_) => setState(() {
//                   pickMode = 'course';
//                   selectedItems.clear();
//                 }),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//
//           // chips of items
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: (pickMode == 'subject' ? subjectList : courseList).isNotEmpty
//                 ? (pickMode == 'subject' ? subjectList : courseList).map((s) {
//               final isSel = selectedItems.contains(s);
//               return FilterChip(
//                 label: Text(s),
//                 selected: isSel,
//                 selectedColor: Colors.green.shade100,
//                 onSelected: (v) {
//                   setState(() {
//                     if (v) {
//                       selectedItems.add(s);
//                     } else {
//                       selectedItems.remove(s);
//                     }
//                   });
//                 },
//               );
//             }).toList()
//                 : [
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                 child: Text('No ${(pickMode == 'subject') ? 'subjects' : 'courses'} available', style: TextStyle(color: Colors.grey.shade600)),
//               )
//             ],
//           ),
//
//           const SizedBox(height: 16),
//
//           // 2) Class Type
//           _sectionTitle("Class Type"),
//           Wrap(
//             spacing: 8,
//             children: ['Individual', 'Common', 'Crash'].map((type) {
//               final sel = selectedClassType == type;
//               return ChoiceChip(
//                 label: Text(type),
//                 selected: sel,
//                 selectedColor: Colors.blue.shade100,
//                 onSelected: (_) => setState(() => selectedClassType = type),
//               );
//             }).toList(),
//           ),
//
//           const SizedBox(height: 16),
//
//           // 3) Hourly Rates Card (three columns)
//           _sectionTitle("Hourly Rates"),
//           Container(
//             width: double.infinity,
//             margin: const EdgeInsets.only(top: 8),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))]),
//             child: Row(
//               children: [
//                 _rateColumn("1 - 10 hrs", "₹${_fmtCurrency(rateBelow10)}/hr", highlighted == 0),
//                 _dividerV(),
//                 _rateColumn("11 - 30 hrs", "₹${_fmtCurrency(rate10to30)}/hr", highlighted == 1),
//                 _dividerV(),
//                 _rateColumn("31+ hrs", "₹${_fmtCurrency(rateAbove30)}/hr", highlighted == 2),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 14),
//
//           // 4) Pricing Option
//           _sectionTitle("Pricing Option"),
//           Container(
//             margin: const EdgeInsets.only(top: 8),
//             padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
//             child: Column(children: [
//               RadioListTile(
//                 contentPadding: EdgeInsets.zero,
//                 title: const Text("Calculate approximate pricing"),
//                 value: "calculate",
//                 groupValue: pricingOption,
//                 onChanged: (v) => setState(() => pricingOption = v!),
//               ),
//               RadioListTile(
//                 contentPadding: EdgeInsets.zero,
//                 title: const Text("Talk with team (skip price)"),
//                 value: "talk",
//                 groupValue: pricingOption,
//                 onChanged: (v) => setState(() => pricingOption = v!),
//               ),
//             ]),
//           ),
//
//           const SizedBox(height: 12),
//
//           // 5) Hours Slider & Number of Days & Start Date & Time slot (only when calculate)
//           if (pricingOption == "calculate") ...[
//             _sectionTitle("Select Hours"),
//             Container(
//               margin: const EdgeInsets.only(top: 8),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))]),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Slider(
//                     value: selectedHours,
//                     min: 1,
//                     max: 50,
//                     divisions: 49,
//                     label: "${selectedHours.round()} hrs",
//                     onChanged: (v) {
//                       setState(() {
//                         selectedHours = v;
//                         selectedRatePerHour = _rateForHours(selectedHours, widget.pricing);
//                         totalPrice = _calculatePrice(selectedHours, widget.pricing);
//                       });
//                     },
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("${selectedHours.round()} hrs", style: const TextStyle(fontWeight: FontWeight.w600)),
//                       Text("₹${_fmtCurrency(selectedRatePerHour)}/hr", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade700)),
//                     ],
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // Number of Days stepper
//                   Row(
//                     children: [
//                       const Text("Number of Days:", style: TextStyle(fontWeight: FontWeight.w600)),
//                       const SizedBox(width: 12),
//                       Container(
//                         decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
//                         child: Row(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.remove_circle_outline),
//                               onPressed: numberOfDays > 1 ? () => setState(() => numberOfDays--) : null,
//                             ),
//                             Text(numberOfDays.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                             IconButton(
//                               icon: const Icon(Icons.add_circle_outline),
//                               onPressed: () => setState(() => numberOfDays++),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // Class starting date & time-slot row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () async {
//                             final today = DateTime.now();
//                             final picked = await showDatePicker(
//                               context: context,
//                               firstDate: today,
//                               lastDate: today.add(const Duration(days: 365)),
//                               initialDate: startDate ?? today,
//                             );
//                             if (picked != null) {
//                               setState(() => startDate = picked);
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//                             decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.calendar_today_outlined, size: 18),
//                                 const SizedBox(width: 8),
//                                 Text(startDate == null ? "Choose start date" : DateFormat('dd MMM yyyy').format(startDate!)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                           decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
//                           child: Wrap(
//                             spacing: 6,
//                             children: slots.map((slot) {
//                               final isSel = slot == selectedSlot;
//                               return GestureDetector(
//                                 onTap: () => setState(() => selectedSlot = slot),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                                   decoration: BoxDecoration(
//                                     color: isSel ? Colors.blue : Colors.transparent,
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(color: isSel ? Colors.blue : Colors.grey.shade300),
//                                   ),
//                                   child: Text(slot, style: TextStyle(color: isSel ? Colors.white : Colors.black87)),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // Price summary
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                           const Text("Per hour", style: TextStyle(fontSize: 13, color: Colors.black54)),
//                           const SizedBox(height: 4),
//                           Text("₹${_fmtCurrency(selectedRatePerHour)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                         ]),
//                         Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                           const Text("Total", style: TextStyle(fontSize: 13, color: Colors.black54)),
//                           const SizedBox(height: 4),
//                           Text("₹${_fmtCurrency(totalPrice)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
//                         ]),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 14),
//           ],
//
//           // 6) Notes (always visible)
//           _sectionTitle("Notes (optional)"),
//           Container(
//             margin: const EdgeInsets.only(top: 8),
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))]),
//             child: TextField(
//               controller: notesController,
//               maxLines: 3,
//               decoration: const InputDecoration(contentPadding: EdgeInsets.all(12), border: InputBorder.none, hintText: 'Any additional notes for the teacher'),
//             ),
//           ),
//
//           const SizedBox(height: 18),
//
//           // 7) Buttons (Book Now)
//           Row(children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => Navigator.of(context).pop(), // Cancel
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey.shade200,
//                   foregroundColor: Colors.black87,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w700)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _onBookNow,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 child: Text(pricingOption == "calculate" ? "Book Now • ₹${_fmtCurrency(totalPrice)}" : "Talk with Team", style: const TextStyle(fontWeight: FontWeight.w700)),
//               ),
//             ),
//           ]),
//
//           const SizedBox(height: 14),
//         ],
//       ),
//     );
//   }
//
//   // small helpers for UI
//   Widget _sectionTitle(String text) => Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
//   );
//
//   Widget _rateColumn(String title, String subtitle, bool highlight) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//         decoration: BoxDecoration(
//           color: highlight ? Colors.blue.shade50 : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
//             const SizedBox(height: 8),
//             Text(subtitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: highlight ? Colors.blue : Colors.black87)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _dividerV() => const SizedBox(width: 6);
//
// }
