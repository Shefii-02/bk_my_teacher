import 'package:flutter/material.dart';
import '../../../model/course_details_model.dart'; // ✅ ClassItem
import '../../../services/teacher_api_service.dart';

class UpdateDurationSheet extends StatefulWidget {
  final ClassItem cls; // ✅ was CompletedClass
  final VoidCallback? onUpdated;

  const UpdateDurationSheet({
    super.key,
    required this.cls,
    required this.onUpdated,
  });

  @override
  State<UpdateDurationSheet> createState() => _UpdateDurationSheetState();
}

class _UpdateDurationSheetState extends State<UpdateDurationSheet> {
  late TimeOfDay _actualStart;
  late TimeOfDay _actualEnd;
  final TextEditingController _noteCtrl = TextEditingController();
  bool _isSaving = false;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    // ✅ parse from ClassItem.timeStart / timeEnd (ISO datetime strings)
    // _actualStart = _parseFromIso(widget.cls.timeStart);
    // _actualEnd = _parseFromIso(widget.cls.timeEnd);

    _actualStart = widget.cls.actualStarted != '' ? _parseFromIso(widget.cls.actualStarted) : _parseFromIso(widget.cls.timeStart);
    _actualEnd =  widget.cls.actualEnded != '' ? _parseFromIso(widget.cls.actualEnded) : _parseFromIso(widget.cls.timeEnd);
    _noteCtrl.text = widget.cls.notes ?? '';
  }

  // ✅ parses ISO datetime "2024-01-01T09:00:00" → TimeOfDay(9, 0)
  TimeOfDay _parseFromIso(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String _formatDiff() {
    final scheduled =
        _toMinutes(_parseFromIso(widget.cls.timeEnd)) -
        _toMinutes(_parseFromIso(widget.cls.timeStart));
    final actual = (_toMinutes(_actualEnd) - _toMinutes(_actualStart)).clamp(
      0,
      1440,
    );
    final diff = actual - scheduled;
    final h = actual ~/ 60;
    final m = actual % 60;
    final label = h > 0 ? '${h}h ${m}min' : '${m}min';
    if (diff == 0) return 'Actual: $label · Same as scheduled';
    if (diff > 0) return 'Actual: $label · ${diff}min more than scheduled';
    return 'Actual: $label · ${(-diff)}min less than scheduled';
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _actualStart : _actualEnd,
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _actualStart = picked;
        else
          _actualEnd = picked;
      });
    }
  }

  Future<void> _save() async {
    if (_toMinutes(_actualEnd) <= _toMinutes(_actualStart)) {
      setState(() {
        _message = 'End time must be after start time';
        _isError = true;
      });
      return;
    }

    setState(() => _isSaving = true);

    try {
      await TeacherApiService().updateClassDuration(
        classId: widget.cls.id,
        actualStart: _combineDateTime(widget.cls.timeStart, _actualStart),
        actualEnd: _combineDateTime(widget.cls.timeStart, _actualEnd),
        note: _noteCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onUpdated!();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duration updated successfully')),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
        _message = 'Failed to update duration';
        _isError = true;
      });
    }
  }

  // ✅ format TimeOfDay for read-only display
  String _fmtTime(TimeOfDay t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ap = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }

  DateTime _combineDateTime(String date, TimeOfDay time) {
    final d = DateTime.parse(date); // from cls.date
    return DateTime(d.year, d.month, d.day, time.hour, time.minute);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ scheduled times parsed once for display
    final ClassItem = widget.cls;
    final scheduledStart = _parseFromIso(ClassItem.timeStart);
    final scheduledEnd = _parseFromIso(ClassItem.timeEnd);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Update Duration',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          // ✅ cls.title + cls.date from ClassItem
                          '${widget.cls.title} · ${widget.cls.date}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F0F0),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Scheduled (read-only) ────────────────────────────
                  const _FieldLabel('Scheduled time (read-only)'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _ReadOnlyField(
                          // ✅ format from parsed TimeOfDay
                          value: _fmtTime(scheduledStart),
                          icon: Icons.access_time,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ReadOnlyField(
                          value: _fmtTime(scheduledEnd),
                          icon: Icons.access_time_filled,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const _FieldLabel('Actual start time'),
                  const SizedBox(height: 6),
                  _TimePicker(time: _actualStart, onTap: () => _pickTime(true)),

                  const SizedBox(height: 12),

                  const _FieldLabel('Actual end time'),
                  const SizedBox(height: 6),
                  _TimePicker(time: _actualEnd, onTap: () => _pickTime(false)),

                  const SizedBox(height: 12),

                  const _FieldLabel('Duration note (optional)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Extended due to Q&A session',
                      hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF1D9E75),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Duration info ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5EE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Color(0xFF0F6E56),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDiff(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0F6E56),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_message != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isError
                            ? const Color(0xFFFFEBEE)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _isError
                              ? const Color(0xFFC62828)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9E75),
                        foregroundColor: Colors.white,
                        elevation: 0,
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
                          : const Text(
                              'Update Duration',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small widgets (unchanged) ──────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF757575),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final IconData icon;
  const _ReadOnlyField({required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimePicker({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 16,
              color: Color(0xFF1D9E75),
            ),
            const SizedBox(width: 8),
            Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }
}
