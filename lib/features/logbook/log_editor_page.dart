import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'log_controller.dart';
import 'models/log_model.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final LogController controller;

  const LogEditorPage({super.key, this.log, required this.controller});

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  String selectedType = "Pribadi";
  String selectedCategory = "Mechanical";
  bool isPublic = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.log?.title ?? "");
    _descController =
        TextEditingController(text: widget.log?.description ?? "");

    /// load data saat edit
    if (widget.log != null) {
      selectedType = widget.log!.type;
      selectedCategory = widget.log!.category;
      isPublic = widget.log!.isPublic;
    }

    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      return;
    }

    if (widget.log == null) {
      /// CREATE
      await widget.controller.addLog(
        _titleController.text,
        _descController.text,
        selectedType,        
        selectedCategory,   
        widget.controller.userId,
        "team_001",
        isPublic,
      );
    } else {
      /// UPDATE
      await widget.controller.updateLog(
        widget.log!,
        _titleController.text,
        _descController.text,
        selectedType,      
        selectedCategory,  
        isPublic,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Catatan berhasil disimpan")),
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.log == null ? "Catatan Baru" : "Edit Catatan",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            labelStyle: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: "Editor"),
              Tab(text: "Pratinjau"),
            ],
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: Color(0xFFF3E7FF)),
              onPressed: _save,
            )
          ],
        ),

        body: TabBarView(
          children: [

            /// TAB EDITOR
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  TextField(
                    controller: _titleController,
                    style: textTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: "Judul",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// TYPE DROPDOWN
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: "Jenis Catatan",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Pribadi",
                        child: Text("Pribadi"),
                      ),
                      DropdownMenuItem(
                        value: "Pekerjaan",
                        child: Text("Pekerjaan"),
                      ),
                      DropdownMenuItem(
                        value: "Urgent",
                        child: Text("Urgent"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  /// CATEGORY DROPDOWN
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Kategori Proyek",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Mechanical",
                        child: Text("Mechanical"),
                      ),
                      DropdownMenuItem(
                        value: "Electronic",
                        child: Text("Electronic"),
                      ),
                      DropdownMenuItem(
                        value: "Software",
                        child: Text("Software"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  /// PRIVACY
                  SwitchListTile(
                    title: Text(
                      "Public",
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "Jika aktif, anggota tim dapat melihat catatan ini",
                      style: textTheme.bodySmall,
                    ),
                    value: isPublic,
                    onChanged: (value) {
                      setState(() {
                        isPublic = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  /// DESCRIPTION
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _descController,
                        style: textTheme.bodyMedium,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Tulis laporan dengan Markdown...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// TAB PREVIEW
            Padding(
              padding: const EdgeInsets.all(16),
              child: Markdown(
                data: _descController.text,
                styleSheet:
                    MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: textTheme.bodyMedium,
                  h1: textTheme.titleLarge,
                  h2: textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}