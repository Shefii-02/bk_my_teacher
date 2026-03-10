import 'dart:io';

import 'package:flutter/material.dart';
import '../../../model/course_details_model.dart';
import '../../../services/teacher_api_service.dart';
import 'course_details_content.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

class CourseDetailsPage extends StatefulWidget {
  final int courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late Future<CourseDetails> futureDetails;
  final TextEditingController _classTitleCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _formMessage;
  Color _formMessageColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  // ─── Load / Refresh ────────────────────────────────────────────────────────

  void _loadDetails() {
    futureDetails = TeacherApiService().fetchTeacherCourseSummary(
      widget.courseId,
    );
  }

  Future<void> _refreshDetails() async {
    setState(() {
      _loadDetails();
    });
  }

  // ─── Bottom Sheet: Options ─────────────────────────────────────────────────

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.video_call, color: Colors.blue),
                title: const Text("Add Class"),
                onTap: () {
                  Navigator.pop(context);
                  _showAddClassBottomSheet(courseId: widget.courseId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.green),
                title: const Text("Add Material"),
                onTap: () {
                  Navigator.pop(context);
                  _showAddMaterialBottomSheet(courseId: widget.courseId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CourseDetails>(
        future: futureDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final details = snapshot.data!;

          return Scaffold(
            appBar: AppBar(title: Text(details.course.title)),
            body: RefreshIndicator(
              onRefresh: _refreshDetails,
              child: CourseDetailsContent(course: details),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _showAddOptions,
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded, size: 28),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  // ─── Bottom Sheet: Add Material ────────────────────────────────────────────

  void _showAddMaterialBottomSheet({required int courseId}) {
    final titleCtrl = TextEditingController();
    String? selectedType;
    File? selectedFile;
    String? selectedFileName;
    String? inlineMessage;
    Color messageColor = Colors.red;

    // Voice recording state
    final AudioRecorder recorder = AudioRecorder();
    final AudioPlayer player = AudioPlayer();
    bool isRecording = false;
    bool isPlaying = false;
    Duration recordedDuration = Duration.zero;
    String? recordedPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final types = [
              _FileTypeOption(
                label: 'PDF',
                icon: Icons.picture_as_pdf_rounded,
                color: const Color(0xFFE53935),
                value: 'pdf',
              ),
              _FileTypeOption(
                label: 'Image',
                icon: Icons.image_rounded,
                color: const Color(0xFF1E88E5),
                value: 'image',
              ),
              _FileTypeOption(
                label: 'Voice',
                icon: Icons.mic_rounded,
                color: const Color(0xFF43A047),
                value: 'voice',
              ),
            ];

            // ── Pick file (PDF / Image) ─────────────────────────────────────
            Future<void> pickFile() async {
              FileType fileType;
              List<String>? allowedExtensions;

              if (selectedType == 'pdf') {
                fileType = FileType.custom;
                allowedExtensions = ['pdf'];
              } else {
                fileType = FileType.image;
              }

              final result = await FilePicker.platform.pickFiles(
                type: fileType,
                allowedExtensions: allowedExtensions,
              );

              if (result != null && result.files.single.path != null) {
                setStateModal(() {
                  selectedFile = File(result.files.single.path!);
                  selectedFileName = result.files.single.name;
                });
              }
            }

            // ── Start recording ────────────────────────────────────────────
            Future<void> startRecording() async {
              final micStatus = await Permission.microphone.status;

              if (micStatus.isDenied) {
                final result = await Permission.microphone.request();
                if (!result.isGranted) {
                  // Permission denied — show settings dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Microphone Permission'),
                      content: const Text(
                        'Microphone access is required to record voice messages. '
                        'Please enable it in app settings.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            openAppSettings(); // from permission_handler
                          },
                          child: const Text('Open Settings'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
              }

              if (micStatus.isPermanentlyDenied) {
                openAppSettings();
                return;
              }

              final dir = await getTemporaryDirectory();
              final path =
                  '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

              await recorder.start(
                const RecordConfig(encoder: AudioEncoder.aacLc),
                path: path,
              );

              // Timer to track duration
              recordedDuration = Duration.zero;
              Future.doWhile(() async {
                await Future.delayed(const Duration(seconds: 1));
                if (!isRecording) return false;
                setStateModal(() {
                  recordedDuration += const Duration(seconds: 1);
                });
                return true;
              });

              setStateModal(() {
                isRecording = true;
                recordedPath = path;
                selectedFile = null;
                selectedFileName = null;
              });
            }

            // ── Stop recording ─────────────────────────────────────────────
            Future<void> stopRecording() async {
              final path = await recorder.stop();
              if (path != null) {
                setStateModal(() {
                  isRecording = false;
                  selectedFile = File(path);
                  selectedFileName =
                      'voice_message_${_formatDuration(recordedDuration)}.m4a';
                });
              }
            }

            // ── Play / pause preview ───────────────────────────────────────
            Future<void> togglePlayback() async {
              if (isPlaying) {
                await player.pause();
                setStateModal(() => isPlaying = false);
              } else {
                if (selectedFile != null) {
                  await player.play(DeviceFileSource(selectedFile!.path));
                  setStateModal(() => isPlaying = true);
                  player.onPlayerComplete.listen((_) {
                    setStateModal(() => isPlaying = false);
                  });
                }
              }
            }

            // ── Submit ─────────────────────────────────────────────────────
            Future<void> submit() async {
              if (titleCtrl.text.trim().isEmpty) {
                setStateModal(() {
                  inlineMessage = 'Please enter a title';
                  messageColor = Colors.red;
                });
                return;
              }
              if (selectedType == null) {
                setStateModal(() {
                  inlineMessage = 'Please select a file type';
                  messageColor = Colors.red;
                });
                return;
              }
              if (selectedFile == null) {
                setStateModal(() {
                  inlineMessage = selectedType == 'voice'
                      ? 'Please record a voice message'
                      : 'Please pick a file';
                  messageColor = Colors.red;
                });
                return;
              }

              // TODO: Upload selectedFile to your API
              // Example:
              await TeacherApiService().uploadMaterial(
                courseId: courseId,
                title: titleCtrl.text.trim(),
                type: selectedType!,
                file: selectedFile!,
                position: 0,
              );

              setStateModal(() {
                inlineMessage = 'Material uploaded successfully!';
                messageColor = Colors.green;
              });

              await player.stop();

              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Material Added")));
                _refreshDetails(); // reload list
              });
            }

            // ── UI ─────────────────────────────────────────────────────────
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 12,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Material",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await recorder.stop();
                            await player.stop();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF0F0F0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Inline alert
                    if (inlineMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: messageColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: messageColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              messageColor == Colors.green
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: messageColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                inlineMessage!,
                                style: TextStyle(color: messageColor),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── File Type Selector ───────────────────────────────────
                    const _SectionLabel(label: "File Type"),
                    const SizedBox(height: 10),
                    Row(
                      children: types.map((t) {
                        final isSelected = selectedType == t.value;
                        final isLast = t.value == 'voice';
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setStateModal(() {
                                selectedType = t.value;
                                selectedFile = null;
                                selectedFileName = null;
                                isRecording = false;
                                isPlaying = false;
                                recordedDuration = Duration.zero;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: isLast ? 0 : 8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? t.color.withOpacity(0.12)
                                    : const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? t.color
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    t.icon,
                                    color: isSelected ? t.color : Colors.grey,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    t.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? t.color : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Title ──────────────────────────────────────────────
                    const _SectionLabel(label: "Title"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Enter material title",
                        hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                        prefixIcon: const Icon(
                          Icons.title_rounded,
                          color: Color(0xFF6C63FF),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F7FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFEEEEEE),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C63FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── File / Voice Section ───────────────────────────────
                    const _SectionLabel(label: "File"),
                    const SizedBox(height: 8),

                    // VOICE UI
                    if (selectedType == 'voice') ...[
                      _VoiceRecorderWidget(
                        isRecording: isRecording,
                        isPlaying: isPlaying,
                        hasRecording: selectedFile != null,
                        duration: recordedDuration,
                        fileName: selectedFileName,
                        onStartRecording: startRecording,
                        onStopRecording: stopRecording,
                        onTogglePlayback: togglePlayback,
                        onDelete: () {
                          setStateModal(() {
                            selectedFile = null;
                            selectedFileName = null;
                            recordedDuration = Duration.zero;
                            isPlaying = false;
                          });
                        },
                      ),
                    ]
                    // PDF / IMAGE FILE PICKER UI
                    else ...[
                      GestureDetector(
                        onTap: selectedType != null ? pickFile : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: selectedType == null
                                ? const Color(0xFFF0F0F0)
                                : const Color(0xFFF7F7FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedFile != null
                                  ? const Color(0xFF6C63FF)
                                  : const Color(0xFFDDDDDD),
                              width: selectedFile != null ? 1.5 : 1,
                            ),
                          ),
                          child: selectedFile == null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_file_rounded,
                                      color: selectedType == null
                                          ? Colors.grey[400]
                                          : const Color(0xFF6C63FF),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      selectedType == null
                                          ? "Select a file type first"
                                          : "Tap to pick a file",
                                      style: TextStyle(
                                        color: selectedType == null
                                            ? Colors.grey[400]
                                            : const Color(0xFF6C63FF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF6C63FF,
                                        ).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.insert_drive_file_rounded,
                                        color: Color(0xFF6C63FF),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        selectedFileName ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setStateModal(() {
                                          selectedFile = null;
                                          selectedFileName = null;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── Submit ─────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Upload Material",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Bottom Sheet: Add Class ───────────────────────────────────────────────

  void _showAddClassBottomSheet({required int courseId}) {
    // Reset form fields before opening
    _classTitleCtrl.clear();
    _selectedDate = null;
    _startTime = null;
    _endTime = null;
    _formMessage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const Text(
                      "Create Class",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Inline alert
                    _buildInlineAlert(),

                    const SizedBox(height: 8),

                    // Class Title
                    TextField(
                      controller: _classTitleCtrl,
                      decoration: const InputDecoration(
                        labelText: "Class Title",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Date picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Class Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedDate == null
                                ? "--/--/----"
                                : "${_selectedDate!.day.toString().padLeft(2, '0')}-"
                                      "${_selectedDate!.month.toString().padLeft(2, '0')}-"
                                      "${_selectedDate!.year}",
                            style: TextStyle(
                              color: _selectedDate == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateModal(() => _selectedDate = picked);
                        }
                      },
                    ),

                    const Divider(height: 1),

                    // Start Time
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _startTime == null
                                ? "--:-- AM/PM"
                                : _startTime!.format(context),
                            style: TextStyle(
                              color: _startTime == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setStateModal(() => _startTime = picked);
                        }
                      },
                    ),

                    const Divider(height: 1),

                    // End Time
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _endTime == null
                                ? "--:-- AM/PM"
                                : _endTime!.format(context),
                            style: TextStyle(
                              color: _endTime == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setStateModal(() => _endTime = picked);
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitClass(courseId, setStateModal),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Submit Class ──────────────────────────────────────────────────────────

  Future<void> _submitClass(int courseId, StateSetter setStateModal) async {
    if (_classTitleCtrl.text.trim().isEmpty) {
      _showMessage(
        "Enter class title",
        isError: true,
        setStateModal: setStateModal,
      );
      return;
    }

    if (_selectedDate == null) {
      _showMessage(
        "Select class date",
        isError: true,
        setStateModal: setStateModal,
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      _showMessage(
        "Select start & end time",
        isError: true,
        setStateModal: setStateModal,
      );
      return;
    }

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (endMinutes <= startMinutes) {
      _showMessage(
        "End time must be after start time",
        isError: true,
        setStateModal: setStateModal,
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final payload = {
      "course_id": courseId,
      "title": _classTitleCtrl.text.trim(),
      "start_time": startDateTime.toIso8601String(),
      "end_time": endDateTime.toIso8601String(),
    };

    try {
      final response = await TeacherApiService().createCourseClass(payload);

      if (response['status'] == true) {
        _showMessage(
          response['message'],
          isError: false,
          setStateModal: setStateModal,
        );

        // ✅ Close sheet and reload list after success
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.pop(context);

          // Reset fields
          _classTitleCtrl.clear();
          _selectedDate = null;
          _startTime = null;
          _endTime = null;
          _formMessage = null;

          // ✅ Reload the course details list
          _refreshDetails();
        });
      } else {
        _showMessage(
          response['message'],
          isError: true,
          setStateModal: setStateModal,
        );
      }
    } catch (e) {
      debugPrint("Submit error: $e");
      _showMessage(
        "Failed to create class",
        isError: true,
        setStateModal: setStateModal,
      );
    }
  }

  // ─── Inline Alert Widget ───────────────────────────────────────────────────

  Widget _buildInlineAlert() {
    if (_formMessage == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
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

  // ─── Show Message Helper ───────────────────────────────────────────────────

  void _showMessage(
    String msg, {
    required bool isError,
    required StateSetter setStateModal,
  }) {
    setStateModal(() {
      _formMessage = msg;
      _formMessageColor = isError ? Colors.red : Colors.green;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setStateModal(() => _formMessage = null);
    });
  }

  // ─── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _classTitleCtrl.dispose();
    super.dispose();
  }
}

// ─── Helper model ─────────────────────────────────────────────────────────────

class _FileTypeOption {
  final String label;
  final IconData icon;
  final Color color;
  final String value;

  const _FileTypeOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
  });
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF888888),
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─── Voice Recorder Widget ────────────────────────────────────────────────────

class _VoiceRecorderWidget extends StatelessWidget {
  final bool isRecording;
  final bool isPlaying;
  final bool hasRecording;
  final Duration duration;
  final String? fileName;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onTogglePlayback;
  final VoidCallback onDelete;

  const _VoiceRecorderWidget({
    required this.isRecording,
    required this.isPlaying,
    required this.hasRecording,
    required this.duration,
    required this.fileName,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onTogglePlayback,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // ── Recording in progress ──────────────────────────────────────────────
    if (isRecording) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            // Animated recording indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PulsingDot(),
                const SizedBox(width: 10),
                const Text(
                  "Recording...",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatDuration(duration),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            // Stop button
            GestureDetector(
              onTap: onStopRecording,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.stop_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap to stop",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // ── Has a recording ────────────────────────────────────────────────────
    if (hasRecording) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FFF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF43A047)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Play / pause
                GestureDetector(
                  onTap: onTogglePlayback,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Voice Message",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Color(0xFF43A047),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Re-record option
            TextButton.icon(
              onPressed: () {
                onDelete();
                onStartRecording();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text("Re-record"),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // ── Idle: tap to record ────────────────────────────────────────────────
    return GestureDetector(
      onTap: onStartRecording,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FFF7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF43A047).withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Color(0xFF43A047),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tap to start recording",
              style: TextStyle(
                color: Color(0xFF43A047),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Record your voice message",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pulsing red dot for recording indicator ──────────────────────────────────

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Duration formatter ───────────────────────────────────────────────────────

String _formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
