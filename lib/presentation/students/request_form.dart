import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import '../../model/grade_board_subject_model.dart';
import '../../services/api_service.dart';
import '../widgets/requests_bottom_sheet.dart';
import '../widgets/show_success_alert.dart';

class RequestForm extends StatefulWidget {
  const RequestForm({super.key});

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final TextEditingController fromCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();
  final TextEditingController otherBoardCtrl = TextEditingController();
  final TextEditingController otherSubjectCtrl = TextEditingController();

  List<Grade> grades = [];
  Grade? selectedGrade;
  Board? selectedBoard;
  Subject? selectedSubject;

  bool _loading = true; // for fetching grades
  bool _submitting = false; // for form submission

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final List<Grade> res = await ApiService()
        .fetchGradesWithBoardsAndSubjects();

    if (res.isNotEmpty) {
      setState(() {
        grades = res;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  Future<void> _submit() async {
    // 🔹 Validation checks one by one
    if (fromCtrl.text.trim().isEmpty) {
      _showError("Please enter where you are from.");
      return;
    }

    if (selectedGrade == null) {
      _showError("Please select a grade.");
      return;
    }

    if (selectedBoard == null) {
      _showError("Please select a board or university or skill.");
      return;
    }

    if (selectedSubject == null) {
      _showError("Please select a subject.");
      return;
    }

    if (noteCtrl.text.trim().isEmpty) {
      _showError("Please enter your note or message.");
      return;
    }

    setState(() => _submitting = true); // 🔹 show overlay loader

    final formData = {
      'from': fromCtrl.text,
      'grade': selectedGrade!.name,
      'board': selectedBoard!.name == "Other"
          ? otherBoardCtrl.text
          : selectedBoard!.name,
      'subject': selectedSubject!.name == "Other"
          ? otherSubjectCtrl.text
          : selectedSubject!.name,
      'note': noteCtrl.text,
    };

    final res = await ApiService().submitRequestForm(formData);

    setState(() => _submitting = false); // 🔹 hide loader

    showSuccessAlert(
      context,
      title: res?['status'] == true ? "Success!" : "failed",
      subtitle: res?['message'] ?? 'Submission complete',
      timer: 6,
      color: res?['status'] == true ? Colors.green : Colors.red,
      showButton: false, // 👈 hide/show button easily
    );

    if (res?['status'] == true) {
      _resetForm();
    }

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(res?['message'] ?? 'Submission complete'),
    //     backgroundColor: res?['status'] == true ? Colors.green : Colors.red,
    //   ),
    // );
  }

  void _resetForm() {
    setState(() {
      fromCtrl.clear();
      noteCtrl.clear();
      otherBoardCtrl.clear();
      otherSubjectCtrl.clear();
      selectedGrade = null;
      selectedBoard = null;
      selectedSubject = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              // const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  // color: const Color(0x52B0FFDF),
                  // borderRadius: BorderRadius.circular(20),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.green.withOpacity(0.2),
                  //     blurRadius: 12,
                  //     offset: const Offset(0, 6),
                  //   ),
                  // ],
                ),
                // padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // const Text(
                        //   "Request a Class/Course",
                        //   style: TextStyle(
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.w900,
                        //     color: Colors.black,
                        //   ),
                        // ),
                        TextButton.icon(
                          onPressed: () => _showRequestsBottomSheet(context),
                          icon: const Icon(Icons.history),
                          label: const Text(
                            "View Requested Classes",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 20),

                    _buildField(controller: fromCtrl, label: "You are from?"),
                    const SizedBox(height: 12),

                    _buildDropdown(
                      label: "Select Grade",
                      value: selectedGrade?.name,
                      items: grades.map((g) => g.name).toList(),
                      onTap: () => _showRadioModal(
                        label: "Select Grade",
                        options: grades.map((e) => e.name).toList(),
                        selected: selectedGrade?.name,
                        onSelect: (val) {
                          setState(() {
                            selectedGrade = grades.firstWhere(
                              (g) => g.name == val,
                            );
                            selectedBoard = null;
                            selectedSubject = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedGrade != null)
                      _buildDropdown(
                        label: "Select Board/University/Skill",
                        value: selectedBoard?.name,
                        items:
                            selectedGrade!.boards
                                .map((b) => b.name)
                                .toList() +
                            ["Other"],
                        onTap: () => _showRadioModal(
                          label: "Select Board/University/Skill",
                          options:
                              selectedGrade!.boards
                                  .map((b) => b.name)
                                  .toList() +
                              ["Other"],
                          selected: selectedBoard?.name,
                          onSelect: (val) {
                            setState(() {
                              selectedBoard = val == "Other"
                                  ? Board(
                                      id: 999,
                                      name: "Other",
                                      subjects: [],
                                    )
                                  : selectedGrade!.boards.firstWhere(
                                      (b) => b.name == val,
                                    );
                              selectedSubject = null;
                            });
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (selectedBoard?.name == "Other")
                      _buildField(
                        controller: otherBoardCtrl,
                        label: "Enter your Board/University/Skill",
                      ),
                    const SizedBox(height: 12),
                    // && selectedBoard!.name != "Other"
                    if (selectedBoard != null)
                      Column(
                        children: [
                          _buildDropdown(
                            label: "Select Subject",
                            value: selectedSubject?.name,
                            items:
                                selectedBoard!.subjects
                                    .map((s) => s.name)
                                    .toList() +
                                ["Other"],
                            onTap: () => _showRadioModal(
                              label: "Select Subject",
                              options:
                                  selectedBoard!.subjects
                                      .map((s) => s.name)
                                      .toList() +
                                  ["Other"],
                              selected: selectedSubject?.name,
                              onSelect: (val) {
                                setState(() {
                                  if (val == "Other") {
                                    selectedSubject = Subject(
                                      name: "Other",
                                      id: -1,
                                    ); // temp subject
                                  } else {
                                    selectedSubject = selectedBoard!.subjects
                                        .firstWhere((s) => s.name == val);
                                  }
                                });
                              },
                            ),
                          ),
                          if (selectedSubject?.name == "Other")
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                _buildField(
                                  controller: otherSubjectCtrl,
                                  label: "Enter your Subject/Skill",
                                ),
                              ],
                            ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: noteCtrl,
                      label: "Do you want to tell me something?",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 28),

                    Center(
                      child: NeoPopTiltedButton(
                        isFloating: true,
                        onTapUp: _submitting ? null : _submit, // disable tap when submitting
                        decoration: const NeoPopTiltedButtonDecoration(
                          color: Color(0xFF70E183),
                          plunkColor: Color(0xFFE8F9E8),
                          shadowColor: Color(0xFF2A3B2A),
                          showShimmer: true,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 15),
                          child: _submitting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Submit Request',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                  ],
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87, fontSize: 12),
        filled: true,
        fillColor: Colors.green.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Label
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // 🔹 Dropdown Container
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? "Select $label",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value == null ? Colors.black54 : Colors.black87,
                      fontSize: 13,
                      fontWeight: value == null
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildDropdown({
  //   required String label,
  //   required String? value,
  //   required List<String> items,
  //   required VoidCallback onTap,
  // }) {
  //   return InkWell(
  //     onTap: onTap,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
  //       decoration: BoxDecoration(
  //         color: Colors.green.shade50,
  //         borderRadius: BorderRadius.circular(10),
  //         border: Border.all(color: Colors.green.shade100),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(value ?? label, style: TextStyle(color: value == null ? Colors.black54 : Colors.black87,)),
  //           const Icon(Icons.arrow_drop_down),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showRadioModal({
    required String label,
    required List<String> options,
    required String? selected,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? temp = selected;
        return StatefulBuilder(
          builder: (context, setStateModal) => Column(
            children: [
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
              const Divider(),
              Expanded(
                child: ListView(
                  children: options.map((v) {
                    return RadioListTile<String>(
                      title: Text(v),
                      value: v,
                      groupValue: temp,
                      onChanged: (val) => setStateModal(() => temp = val),
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (temp != null) onSelect(temp!);
                  Navigator.pop(context);
                },
                child: const Text("Select"),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showRequestsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => const RequestsBottomSheet(),
    );
  }

}
