import 'package:flutter/material.dart';
import '../../../services/teacher_api_service.dart';

enum AttendanceStatus { present, absent, late, nullVal }

class AttendanceSheet extends StatefulWidget {
  final String classId;
  final String classTitle;
  final String classDate;
  final VoidCallback? onSaved;

  const AttendanceSheet({
    super.key,
    required this.classId,
    required this.classTitle,
    required this.classDate,
    required this.onSaved,
  });

  @override
  State<AttendanceSheet> createState() => _AttendanceSheetState();
}

class _AttendanceSheetState extends State<AttendanceSheet> {
  List<StudentAttendance>? _students;
  bool _loadingStudents = true;
  bool _isSaving = false;
  String? _fetchError;
  String? _saveMessage;
  bool _saveIsError = false;
  String _search = '';
  List<StudentAttendance> _filteredStudents = [];
  AttendanceStatus? _statusFilter; // null = show all

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  // ── Fetch students + existing attendance for this class ────────────────────

  Future<void> _fetchStudents() async {
    setState(() {
      _loadingStudents = true;
      _fetchError = null;
    });
    try {
      // API returns students + their existing attendance status (if taken before)
      final result = await TeacherApiService().fetchClassStudentsWithAttendance(
        widget.classId,
      );
      setState(() {
        _students = result;
        _filteredStudents = result;
        _loadingStudents = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _fetchError = 'Failed to load students. Tap to retry.';
        _loadingStudents = false;
      });
    }
  }

  void _filterStudents(String value) {
    setState(() {
      _search = value;

      _filteredStudents = _students!.where((s) {
        final matchesSearch =
            s.name.toLowerCase().contains(value.toLowerCase()) ||
            s.rollNumber.toLowerCase().contains(value.toLowerCase());

        final matchesStatus = _statusFilter == null
            ? true
            : s.status == _statusFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _setStatusFilter(AttendanceStatus? status) {
    setState(() {
      _statusFilter = status;
    });

    _filterStudents(_search); // reapply filter
  }
  // void _filterStudents(String value) {
  //   setState(() {
  //     _search = value;
  //
  //     _filteredStudents = _students!.where((s) {
  //       final matchesSearch =
  //           s.name.toLowerCase().contains(value.toLowerCase()) ||
  //               s.rollNumber.toLowerCase().contains(value.toLowerCase());
  //
  //       final matchesStatus = _statusFilter == null
  //           ? true
  //           : s.status == _statusFilter;
  //
  //       return matchesSearch && matchesStatus;
  //     }).toList();
  //   });
  // }

  // ── Helpers ────────────────────────────────────────────────────────────────

  int get _presentCount =>
      _students?.where((s) => s.status == AttendanceStatus.present).length ?? 0;

  int get _absentCount =>
      _students?.where((s) => s.status == AttendanceStatus.absent).length ?? 0;

  int get _lateCount =>
      _students?.where((s) => s.status == AttendanceStatus.late).length ?? 0;

  int get _pendingCount =>
      _students?.where((s) => s.status == AttendanceStatus.nullVal).length ?? 0;

  int get _totalCount => _students?.length ?? 0;

  void _markAll(AttendanceStatus status) {
    if (_students == null) return;
    setState(() {
      for (final s in _students!) {
        s.status = status;
      }
      _filterStudents(_search);
    });
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_students == null) return;
    setState(() => _isSaving = true);
    try {
      await TeacherApiService().saveAttendance(
        classId: widget.classId,
        records: _students!
            .map(
              (s) => {
                'student_id': s.studentId,
                'status': s.status == AttendanceStatus.nullVal
                    ? null
                    : s.status.name, // 'present' | 'absent' | 'late'
              },
            )
            .toList(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved!();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully')),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
        _saveMessage = 'Failed to save. Please try again.';
        _saveIsError = true;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85, // ✅ FIX HEIGHT
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            if (_loadingStudents)
              _buildLoading()
            else if (_fetchError != null)
              _buildError()
            else
              _buildContent(),
          ],
        ),
      ),
    );
  }

  // ── Handle ─────────────────────────────────────────────────────────────────

  Widget _buildHandle() => Center(
    child: Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Take Attendance',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.classTitle} · ${widget.classDate}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
          style: IconButton.styleFrom(backgroundColor: const Color(0xFFF0F0F0)),
        ),
      ],
    ),
  );

  // ── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoading() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Column(
      children: [
        CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C63FF)),
        SizedBox(height: 12),
        Text(
          'Loading students...',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        ),
      ],
    ),
  );

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFBDBDBD)),
        const SizedBox(height: 12),
        Text(
          _fetchError!,
          style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _fetchStudents,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Retry'),
        ),
      ],
    ),
  );

  // ── Main content ───────────────────────────────────────────────────────────

  Widget _buildContent() {
    // final students = _students!;
    final students = _filteredStudents;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Toolbar ─────────────────────────────────────────────────────
          _AttendanceToolbar(
            pendingCount: _pendingCount,
            totalCount: _totalCount,
            presentCount: _presentCount,
            absentCount: _absentCount,
            lateCount: _lateCount,
            onMarkAll: _markAll,
          ),

          // ── Save error ───────────────────────────────────────────────────
          if (_saveMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _InlineAlert(
                message: _saveMessage!,
                isError: _saveIsError,
              ),
            ),

          Row(
            children: [
              // ✅ SEARCH (3/4)
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    onChanged: _filterStudents,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ✅ FILTERS (1/4)
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterBtn(
                        label: 'All',
                        isActive: _statusFilter == null,
                        onTap: () => _setStatusFilter(null),
                      ),
                      const SizedBox(width: 6),

                      _FilterBtn(
                        label: 'Pending',
                        isActive: _statusFilter == AttendanceStatus.nullVal,
                        onTap: () => _setStatusFilter(AttendanceStatus.nullVal),
                      ),
                      const SizedBox(width: 6),

                      _FilterBtn(
                        label: 'Present',
                        isActive: _statusFilter == AttendanceStatus.present,
                        onTap: () => _setStatusFilter(AttendanceStatus.present),
                      ),
                      const SizedBox(width: 6),

                      _FilterBtn(
                        label: 'Absent',
                        isActive: _statusFilter == AttendanceStatus.absent,
                        onTap: () => _setStatusFilter(AttendanceStatus.absent),
                      ),
                      const SizedBox(width: 6),

                      _FilterBtn(
                        label: 'Late',
                        isActive: _statusFilter == AttendanceStatus.late,
                        onTap: () => _setStatusFilter(AttendanceStatus.late),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Student list ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              itemBuilder: (_, i) => _StudentRow(
                student: students[i],
                onChanged: (status) {
                  setState(() {
                    final original = _students!.firstWhere(
                      (s) => s.studentId == students[i].studentId,
                    );
                    original.status = status;
                    students[i].status = status;
                  });
                  _filterStudents(_search); // 🔥 ADD THIS
                },
              ),
            ),
          ),

          // ── Save button ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: const Color(0xFFBBB8FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save Attendance · $_presentCount present, '
                        '$_absentCount absent, $_lateCount late',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterBtn({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}
// ── Toolbar ────────────────────────────────────────────────────────────────────

class _AttendanceToolbar extends StatelessWidget {
  final int totalCount, pendingCount, presentCount, absentCount, lateCount;
  final ValueChanged<AttendanceStatus> onMarkAll;

  const _AttendanceToolbar({
    required this.totalCount,
    required this.pendingCount,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.onMarkAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Column(
        children: [
          // Summary counts
          Row(
            children: [
              const SizedBox(width: 6),
              _CountChip(
                label: 'Pending',
                count: pendingCount,
                color: const Color(0xFFF57F17),
                bg: const Color(0xFFFFF8E1),
              ),
              _CountChip(
                label: 'Present',
                count: presentCount,
                color: const Color(0xFF2E7D32),
                bg: const Color(0xFFE8F5E9),
              ),
              const SizedBox(width: 6),
              _CountChip(
                label: 'Absent',
                count: absentCount,
                color: const Color(0xFFC62828),
                bg: const Color(0xFFE3F2FD),
              ),
              const SizedBox(width: 6),
              _CountChip(
                label: 'Late',
                count: lateCount,
                color: const Color(0xFFF57F17),
                bg: const Color(0xFFFFF8E1),
              ),
              const Spacer(),
              Text(
                '$totalCount students',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Quick-mark buttons
          Row(
            children: [
              _QuickBtn(
                label: 'Mark all present',
                color: const Color(0xFF2E7D32),
                bg: const Color(0xFFE8F5E9),
                border: const Color(0xFF43A047),
                onTap: () => onMarkAll(AttendanceStatus.present),
              ),
              const SizedBox(width: 6),
              _QuickBtn(
                label: 'Mark all absent',
                color: const Color(0xFFC62828),
                bg: const Color(0xFFFFEBEE),
                border: const Color(0xFFEF9A9A),
                onTap: () => onMarkAll(AttendanceStatus.absent),
              ),
              const SizedBox(width: 6),
              _QuickBtn(
                label: 'Mark all reset',
                color: const Color(0xFF0D8CEF),
                bg: const Color(0xFFFFEBEE),
                border: const Color(0xFF0D8CEF),
                onTap: () => onMarkAll(AttendanceStatus.nullVal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color, bg;
  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    ),
  );
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final Color color, bg, border;
  final VoidCallback onTap;
  const _QuickBtn({
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    ),
  );
}

// ── Student row ────────────────────────────────────────────────────────────────

class _StudentRow extends StatelessWidget {
  final StudentAttendance student;
  final ValueChanged<AttendanceStatus> onChanged;

  const _StudentRow({required this.student, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        // highlight late students subtly
        color: student.status == AttendanceStatus.late
            ? const Color(0xFFFFFDF5)
            : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: student.avatarColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              student.initials,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: student.avatarColor,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name + roll
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  student.rollNumber,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),

          // P / A / L toggle
          _PALToggle(current: student.status, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ── P / A / L segmented toggle ─────────────────────────────────────────────────

class _PALToggle extends StatelessWidget {
  final AttendanceStatus current;
  final ValueChanged<AttendanceStatus> onChanged;

  const _PALToggle({required this.current, required this.onChanged});

  static const _options = [
    (
      status: AttendanceStatus.present,
      label: 'P',
      activeColor: Color(0xFF2E7D32),
      activeBg: Color(0xFFE8F5E9),
    ),
    (
      status: AttendanceStatus.absent,
      label: 'A',
      activeColor: Color(0xFFC62828),
      activeBg: Color(0xFFFFEBEE),
    ),
    (
      status: AttendanceStatus.late,
      label: 'L',
      activeColor: Color(0xFFF57F17),
      activeBg: Color(0xFFFFF8E1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_options.length, (i) {
        final opt = _options[i];
        final isSelected = current == opt.status;
        final isFirst = i == 0;
        final isLast = i == _options.length - 1;

        return GestureDetector(
          onTap: () => onChanged(opt.status),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 30,
            decoration: BoxDecoration(
              color: isSelected ? opt.activeBg : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.horizontal(
                left: isFirst ? const Radius.circular(8) : Radius.zero,
                right: isLast ? const Radius.circular(8) : Radius.zero,
              ),
              border: Border.all(
                color: isSelected
                    ? opt.activeColor.withOpacity(0.5)
                    : const Color(0xFFDDDDDD),
                width: 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              opt.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? opt.activeColor : const Color(0xFFBBBBBB),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Inline alert ───────────────────────────────────────────────────────────────

class _InlineAlert extends StatelessWidget {
  final String message;
  final bool isError;
  const _InlineAlert({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFC62828) : const Color(0xFF2E7D32);
    final bg = isError ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 12, color: color)),
          ),
        ],
      ),
    );
  }
}

// ── Model ──────────────────────────────────────────────────────────────────────

class StudentAttendance {
  final int studentId;
  final String name;
  final String rollNumber;
  final String initials;
  final Color avatarColor;
  AttendanceStatus status;

  StudentAttendance({
    required this.studentId,
    required this.name,
    required this.rollNumber,
    required this.initials,
    required this.avatarColor,
    required this.status,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> j) {
    return StudentAttendance(
      studentId: j['student_id'],
      name: j['name'],
      rollNumber: j['roll_number'] ?? '',
      initials: j['initials'] ?? _initials(j['name']),
      avatarColor: _colorFromHex(j['avatar_color'] ?? '#4A47B0'),
      // if attendance already taken, pre-fill status; default to present
      status: _statusFrom(j['attendance_status']),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  static Color _colorFromHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static AttendanceStatus _statusFrom(String? raw) {
    switch (raw) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.nullVal;
    }
  }
}
