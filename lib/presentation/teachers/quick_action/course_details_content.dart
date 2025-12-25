import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
// import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../model/course_details_model.dart';
import 'package:dio/dio.dart';

class CourseDetailsContent extends StatefulWidget {
  final CourseDetails course;

  const CourseDetailsContent({super.key, required this.course});

  @override
  State<CourseDetailsContent> createState() => _CourseDetailsContentState();
}

class _CourseDetailsContentState extends State<CourseDetailsContent>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.course.course;
    final classes = widget.course.classes;
    final materials = widget.course.materials;

    return Column(
      children: [
        // Banner
        SizedBox(
          width: double.infinity,
          height: 180,
          child: Image.network(info.thumbnailUrl, fit: BoxFit.cover),
        ),

        Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            info.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "About"),
            Tab(text: "Classes"),
            Tab(text: "Materials"),
          ],
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _aboutTab(info),
              _classesTab(classes),
              _materialsTab(materials),
            ],
          ),
        ),
      ],
    );
  }

  // ABOUT TAB
  Widget _aboutTab(CourseInfo c) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ListView(
        children: [
          Text("Description", style: _titleStyle),
          const SizedBox(height: 8),
          Text(c.description),

          const SizedBox(height: 16),
          Text("Duration: ${c.duration}"),
          Text("Level: ${c.level}"),
          Text("Language: ${c.language}"),
          Text("Category: ${c.category}"),

          const SizedBox(height: 16),
          Text("Classes Completed: ${c.completedClasses}/${c.totalClasses}"),
        ],
      ),
    );
  }

  // CLASSES TAB
  Widget _classesTab(ClassGroups cls) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Inner Tab Bar
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Upcoming"),
              Tab(text: "Ongoing"),
              Tab(text: "Completed"),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [
                _buildClassList(cls.upcoming),
                _buildClassList(cls.ongoing),
                _buildClassList(cls.completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList(List<ClassItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text("No classes found"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final e = items[i];

        return Card(
          child: ListTile(
            title: Text(e.title),
            subtitle: Text("${e.date} • ${e.timeStart} - ${e.timeEnd}"),
            trailing: Text(e.classStatus),
          ),
        );
      },
    );
  }

  // MATERIALS TAB
  Widget _materialsTab(List<MaterialItem> materials) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: materials.length,
      itemBuilder: (context, i) {
        final m = materials[i];
        return Card(
          child: ListTile(
            leading: Icon(
              m.fileType == "pdf"
                  ? Icons.picture_as_pdf
                  : Icons.video_file,
            ),
            title: Text(m.title),
            subtitle: Text(m.fileType.toUpperCase()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.file_open),
                  onPressed: () => _openMaterial(m),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadMaterial(m),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextStyle get _titleStyle =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  Future<void> _openMaterial(MaterialItem item) async {
    if (item.fileType == "video") {
      // open video in browser
      await OpenFilex.open(item.fileUrl);
      return;
    }

    if (item.fileType == "pdf") {
      await OpenFilex.open(item.fileUrl);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unsupported file type: ${item.fileType}")),
    );
  }

  Future<void> _downloadMaterial(MaterialItem item) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = "${dir.path}/${item.title}.${item.fileType}";

      await Dio().download(item.fileUrl, savePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloaded to: $savePath")),
      );

      await OpenFilex.open(savePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download Failed: $e")),
      );
    }
  }

}