import 'package:flutter/material.dart';
import '../../../model/task_model.dart';
import '../../../services/teacher_api_service.dart';

enum TaskFilter { all, active, pendingVerify, verified, disabled }

class TaskListingTab extends StatefulWidget {
  final int courseId;
  const TaskListingTab({super.key, required this.courseId});

  @override
  State<TaskListingTab> createState() => _TaskListingTabState();
}

class _TaskListingTabState extends State<TaskListingTab> {
  late Future<List<TaskItem>> _future;
  TaskFilter _filter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    // _future = TeacherApiService().fetchCourseTasks(widget.courseId);
  }

  Future<void> _refresh() async => setState(() => _load());

  List<TaskItem> _filtered(List<TaskItem> all) {
    switch (_filter) {
      case TaskFilter.all:           return all;
      case TaskFilter.active:        return all.where((t) => t.status == 'active').toList();
      case TaskFilter.pendingVerify: return all.where((t) => t.status == 'active' && !t.verified).toList();
      case TaskFilter.verified:      return all.where((t) => t.verified).toList();
      case TaskFilter.disabled:      return all.where((t) => t.status == 'disabled').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TaskItem>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || !snap.hasData) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final tasks = _filtered(snap.data!);
        final active   = tasks.where((t) => t.status == 'active').toList();
        final disabled = tasks.where((t) => t.status == 'disabled').toList();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              // ── Filter chips ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: _FilterRow(
                  current: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                ),
              ),

              // ── Active tasks ───────────────────────────────────────────
              if (active.isNotEmpty) ...[
                _SectionHeader(label: 'Active tasks'),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => _TaskCard(
                      task: active[i],
                      onRefresh: _refresh,
                    ),
                    childCount: active.length,
                  ),
                ),
              ],

              // ── Disabled tasks ─────────────────────────────────────────
              if (disabled.isNotEmpty) ...[
                _SectionHeader(label: 'Disabled tasks'),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => _TaskCard(
                      task: disabled[i],
                      onRefresh: _refresh,
                    ),
                    childCount: disabled.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }
}

// ── Filter row ─────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final TaskFilter current;
  final ValueChanged<TaskFilter> onChanged;

  const _FilterRow({required this.current, required this.onChanged});

  static const _labels = {
    TaskFilter.all:           'All',
    TaskFilter.active:        'Active',
    TaskFilter.pendingVerify: 'Pending verify',
    TaskFilter.verified:      'Verified',
    TaskFilter.disabled:      'Disabled',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: TaskFilter.values.map((f) {
          final isActive = f == current;
          return GestureDetector(
            onTap: () => onChanged(f),
            child: Container(
              margin: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFEEF0FF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF4A47B0)
                      : const Color(0xFFEEEEEE),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _labels[f]!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF4A47B0)
                      : const Color(0xFF757575),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Color(0xFF9E9E9E),
        ),
      ),
    ),
  );
}

// ── Task card ──────────────────────────────────────────────────────────────────

class _TaskCard extends StatefulWidget {
  final TaskItem task;
  final VoidCallback onRefresh;

  const _TaskCard({required this.task, required this.onRefresh});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _studentsExpanded = false;
  bool _loading = false;

  bool get _isDisabled => widget.task.status == 'disabled';

  double get _completionPct =>
      widget.task.totalStudents > 0
          ? widget.task.completedCount / widget.task.totalStudents
          : 0;

  Future<void> _verify() async {
    setState(() => _loading = true);
    try {
      // await TeacherApiService().verifyTask(widget.task.id);
      widget.onRefresh();
    } catch (_) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to verify task')),
      );
    }
  }

  Future<void> _toggleDisable() async {
    setState(() => _loading = true);
    try {
      if (_isDisabled) {
        // await TeacherApiService().enableTask(widget.task.id);
      } else {
        // await TeacherApiService().disableTask(widget.task.id);
      }
      widget.onRefresh();
    } catch (_) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${_isDisabled ? 'enable' : 'disable'} task')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;

    return Opacity(
      opacity: _isDisabled ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Body ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TaskIconBox(task: t),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A2E),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _StatusBadge(task: t),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      _MetaChip(
                        icon: Icons.calendar_today_outlined,
                        label: 'Task: ${t.taskDate}',
                      ),
                      _MetaChip(
                        icon: Icons.event_outlined,
                        label: 'Due: ${t.endDate}',
                      ),
                      _MetaChip(
                        icon: Icons.people_outline,
                        label: '${t.totalStudents} students',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Completion bar ───────────────────────────────────────────
            if (!_isDisabled) ...[
              Container(
                height: 0.5,
                color: const Color(0xFFEEEEEE),
                margin: const EdgeInsets.symmetric(horizontal: 14),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Student completion',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                              Text(
                                '${t.completedCount}/${t.totalStudents} done',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: _completionPct,
                              backgroundColor: const Color(0xFFEEEEEE),
                              color: t.verified
                                  ? const Color(0xFF43A047)
                                  : const Color(0xFF6C63FF),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(_completionPct * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: t.verified
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF4A47B0),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Action buttons ───────────────────────────────────────────
            const Divider(height: 0.5, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.all(10),
              child: _loading
                  ? const Center(
                child: SizedBox(
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : _isDisabled
                  ? Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      label: 'Re-enable',
                      icon: Icons.add_circle_outline_rounded,
                      bg: const Color(0xFFE8F0FF),
                      fg: const Color(0xFF3949AB),
                      border: const Color(0xFF5C6BC0),
                      onTap: _toggleDisable,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Students',
                      icon: Icons.people_outline,
                      bg: Colors.white,
                      fg: const Color(0xFF757575),
                      border: const Color(0xFFEEEEEE),
                      onTap: () => setState(
                            () => _studentsExpanded = !_studentsExpanded,
                      ),
                    ),
                  ),
                ],
              )
                  : Row(
                children: [
                  // Verify button — disabled if already verified
                  Expanded(
                    child: t.verified
                        ? _ActionBtn(
                      label: 'Verified',
                      icon: Icons.check_circle_outline_rounded,
                      bg: const Color(0xFFF5F5F5),
                      fg: const Color(0xFF9E9E9E),
                      border: const Color(0xFFEEEEEE),
                      onTap: null,
                    )
                        : _ActionBtn(
                      label: 'Verify',
                      icon: Icons.verified_outlined,
                      bg: const Color(0xFFE8F5E9),
                      fg: const Color(0xFF2E7D32),
                      border: const Color(0xFF43A047),
                      onTap: _verify,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Disable',
                      icon: Icons.block_outlined,
                      bg: const Color(0xFFFFEBEE),
                      fg: const Color(0xFFC62828),
                      border: const Color(0xFFE53935),
                      onTap: _toggleDisable,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Students',
                      icon: Icons.people_outline,
                      bg: const Color(0xFFF5F4FF),
                      fg: const Color(0xFF4A47B0),
                      border: const Color(0xFF7C6FCD),
                      onTap: () => setState(
                            () => _studentsExpanded = !_studentsExpanded,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Student completion list ───────────────────────────────────
            if (_studentsExpanded) _StudentCompletionList(task: t),
          ],
        ),
      ),
    );
  }
}

// ── Student completion list ────────────────────────────────────────────────────

class _StudentCompletionList extends StatelessWidget {
  final TaskItem task;
  const _StudentCompletionList({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                const Text(
                  'Student completion status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
                ),
                const Spacer(),
                Text(
                  '${task.completedCount} done · '
                      '${task.totalStudents - task.completedCount} pending',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          ...task.students.map((s) => _StudentCompRow(student: s)),
        ],
      ),
    );
  }
}

class _StudentCompRow extends StatelessWidget {
  final TaskStudent student;
  const _StudentCompRow({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: student.avatarColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              student.initials,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: student.avatarColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  student.completed
                      ? 'Completed ${student.completedAt ?? ''}'
                      : 'Not submitted yet',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),

          // ── Completed / Pending chip ─────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: student.completed
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: student.completed
                    ? const Color(0xFF43A047)
                    : const Color(0xFFDDDDDD),
              ),
            ),
            child: Text(
              student.completed ? 'Completed' : 'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: student.completed
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small widgets ──────────────────────────────────────────────────────────────

class _TaskIconBox extends StatelessWidget {
  final TaskItem task;
  const _TaskIconBox({required this.task});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    if (task.status == 'disabled') {
      bg = const Color(0xFFF5F5F5); fg = const Color(0xFF9E9E9E);
      icon = Icons.remove_circle_outline;
    } else if (task.verified) {
      bg = const Color(0xFFE8F5E9); fg = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline_rounded;
    } else {
      bg = const Color(0xFFFFF3E0); fg = const Color(0xFFB85C00);
      icon = Icons.assignment_outlined;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 17, color: fg),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskItem task;
  const _StatusBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg, fg;

    if (task.status == 'disabled') {
      label = 'Disabled'; bg = const Color(0xFFF5F5F5); fg = const Color(0xFF9E9E9E);
    } else if (task.verified) {
      label = 'Verified'; bg = const Color(0xFFE8F5E9); fg = const Color(0xFF2E7D32);
    } else {
      label = 'Active'; bg = const Color(0xFFEEF0FF); fg = const Color(0xFF3949AB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg, fg, border;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}