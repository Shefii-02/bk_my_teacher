import 'dart:async';
import 'package:BookMyTeacher/presentation/students/teacher_search_result_page.dart';
import 'package:flutter/material.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import '../../model/app_state_model.dart';
import '../../model/grade_board_subject_model.dart';
import '../../services/api_service.dart';
import '../widgets/show_success_alert.dart';

class FindTeacherForm extends StatefulWidget {
  const FindTeacherForm({super.key});

  @override
  State<FindTeacherForm> createState() => _FindTeacherFormState();
}

class _FindTeacherFormState extends State<FindTeacherForm> {
  final TextEditingController fromCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();

  List<Grade> grades = [];
  Grade? selectedGrade;
  Board? selectedBoard;

  String? _formMessage;
  Color _formMessageColor = Colors.green;

  AppStateModel? selectedState;
  String? selectedDistrict;

  List<Subject> selectedSubjects = [];
  List<String> selectedModes = [];

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final res = await ApiService().fetchGradesWithBoardsAndSubjects();
    setState(() {
      grades = res;
      _loading = false;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _setFormError(String msg) {
    setState(() {
      _formMessage = msg;
      _formMessageColor = Colors.red;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _formMessage = null);
    });
  }

  Future<void> _submit() async {
    // 🔹 Prevent double click
    if (_submitting) return;

    // 🔹 Validation

    if (selectedGrade == null) {
      // _showError("Please select grade");

      _setFormError("Please select grade");

      return;
    }

    if (selectedBoard == null) {
      _setFormError("Please select board");

      return;
    }

    if (selectedSubjects.isEmpty) {
      // _showError("Please select at least one subject");
      _setFormError("Please select at least one subject");

      return;
    }

    if (selectedModes.isEmpty) {
      // _showError("Please select class mode");
      _setFormError("Please select class mode");

      return;
    }

    final location = fromCtrl.text.trim();

    if (selectedState == null) {
      _setFormError("Enter your State");

      return;
    }

    if (selectedDistrict == null || selectedDistrict!.isEmpty) {
      _setFormError("Enter your District");

      return;
    }

    setState(() => _submitting = true);

    try {
      final payload = {
        "grade": selectedGrade!.name,
        "board": selectedBoard!.name,
        "subjects": selectedSubjects.map((e) => e.name).toList(),
        "modes": selectedModes,

        /// 🔥 NEW (Location)
        "state": selectedState!.name,
        "district": selectedDistrict,
      };

      final res = await ApiService().findingRequestingTeacher(payload);

      final bool success = res?["status"] == true;
      if (!mounted) return;

      if (success) {
        final result = res?["data"] ?? {};

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                TeacherSearchResultPage(filters: payload, result: result),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res?["message"] ?? "Something went wrong")),
        );
      }

      await showSuccessAlert(
        context,
        title: success ? "Success!" : "Failed",
        subtitle: res?["message"] ?? "Something went wrong",
        timer: 2,
        color: success ? Colors.green : Colors.red,
        showButton: false,
      );

      if (success) {
        _resetForm();

        // optional auto close
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _formMessage = "Something went wrong";
        _formMessageColor = Colors.red;
      });

      // Auto hide after 3 sec
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _formMessage = null;
          });
        }
      });

      // _showError("Something went wrong. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _resetForm() {
    fromCtrl.clear();
    noteCtrl.clear();

    setState(() {
      selectedGrade = null;
      selectedBoard = null;
      selectedSubjects = [];
      selectedModes = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInlineAlert(),
          const SizedBox(height: 30),

          /// State
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Select GRADE",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),

          /// GRADE
          _buildDropdown(
            label: "Select Grade",
            value: selectedGrade?.name,
            onTap: () => _showRadioModal(
              label: "Select Grade",
              options: grades.map((e) => e.name).toList(),
              selected: selectedGrade?.name,
              onSelect: (val) {
                setState(() {
                  selectedGrade = grades.firstWhere((g) => g.name == val);
                  selectedBoard = null;
                  selectedSubjects.clear();
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          /// State
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Select Board/University/Skill",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),

          /// BOARD
          _buildDropdown(
            label: "Select Board",
            value: selectedBoard?.name,
            enabled: selectedGrade != null, // 🔥 new param
            onTap: () {
              if (selectedGrade == null) return;

              _showRadioModal(
                label: "Select Board",
                options: selectedGrade!.boards.map((b) => b.name).toList(),
                selected: selectedBoard?.name,
                onSelect: (val) {
                  setState(() {
                    selectedBoard = selectedGrade!.boards.firstWhere(
                      (b) => b.name == val,
                    );
                    selectedSubjects.clear();
                  });
                },
              );
            },
          ),

          const SizedBox(height: 12),

          /// State
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Select Subjects",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),

          /// SUBJECTS MULTI
          // if (selectedBoard != null)
          _buildDropdown(
            label: "Select Subjects",
            value: selectedSubjects.isEmpty
                ? null
                : selectedSubjects.map((e) => e.name).join(", "),
            enabled: selectedGrade != null, // 🔥 new param
            onTap: () => _showMultiSelectModal(),
          ),

          const SizedBox(height: 12),

          /// CLASS MODE
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Class Mode",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: selectedModes.contains("Online"),
                      onChanged: (v) {
                        setState(() {
                          v!
                              ? selectedModes.add("Online")
                              : selectedModes.remove("Online");
                        });
                      },
                    ),
                    const Text("Online"),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: selectedModes.contains("Offline"),
                      onChanged: (v) {
                        setState(() {
                          v!
                              ? selectedModes.add("Offline")
                              : selectedModes.remove("Offline");
                        });
                      },
                    ),
                    const Text("Offline"),
                  ],
                ),
              ),
            ],
          ),

          /// State
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Select State",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          _buildDropdown(
            label: "Select State",
            value: selectedState?.name,
            onTap: () => _showRadioModal(
              label: "Select State",
              options: states.map((s) => s.name).toList(),
              selected: selectedState?.name,
              onSelect: (val) {
                setState(() {
                  selectedState = states.firstWhere((s) => s.name == val);
                  selectedDistrict = null; // reset district
                });
              },
            ),
          ),

          const SizedBox(height: 12),
          _buildDropdown(
            label: "Select District",
            value: selectedDistrict,
            enabled: selectedState != null, // 🔥 disable until state selected
            onTap: () {
              if (selectedState == null) return;

              _showRadioModal(
                label: "Select District",
                options: selectedState!.districts,
                selected: selectedDistrict,
                onSelect: (val) {
                  setState(() {
                    selectedDistrict = val;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 12),

          /// SUBMIT
          NeoPopTiltedButton(
            isFloating: true,
            onTapUp: _submitting ? null : _submit,
            decoration: const NeoPopTiltedButtonDecoration(
              color: Color(0xFF70E183),
              plunkColor: Color(0xFFE8F9E8),
              shadowColor: Color(0xFF2A3B2A),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 60.0,
                vertical: 14,
              ),
              child: _submitting
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      "Search",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInlineAlert() {
    if (_formMessage == null) return const SizedBox();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _formMessageColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _formMessageColor),
      ),
      child: Row(
        children: [
          Icon(
            _formMessageColor == Colors.green
                ? Icons.check_circle
                : Icons.error,
            color: _formMessageColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _formMessage!,
              style: TextStyle(color: _formMessageColor),
            ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGETS =================

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
        filled: true,
        fillColor: Colors.green.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required VoidCallback onTap,
    bool enabled = true, // 🔥 new
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value ?? label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: value == null ? Colors.black54 : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showRadioModal({
    required String label,
    required List<String> options,
    required String? selected,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        String? temp = selected;
        return StatefulBuilder(
          builder: (context, setModal) => Column(
            children: [
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
              Expanded(
                child: ListView(
                  children: options.map((v) {
                    return RadioListTile<String>(
                      title: Text(v),
                      value: v,
                      groupValue: temp,
                      onChanged: (val) {
                        setModal(() => temp = val);
                        onSelect(val!);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMultiSelectModal() {
    final options = selectedBoard!.subjects.map((e) => e.name).toList();
    final temp = selectedSubjects.map((e) => e.name).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) => Column(
            children: [
              const SizedBox(height: 12),
              const Text("Select Subjects", style: TextStyle(fontSize: 16)),
              Expanded(
                child: ListView(
                  children: options.map((v) {
                    final checked = temp.contains(v);
                    return CheckboxListTile(
                      title: Text(v),
                      value: checked,
                      onChanged: (val) {
                        setModal(() {
                          val! ? temp.add(v) : temp.remove(v);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: () {
                  setState(() {
                    selectedSubjects = selectedBoard!.subjects
                        .where((s) => temp.contains(s.name))
                        .toList();
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  "Done",
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
