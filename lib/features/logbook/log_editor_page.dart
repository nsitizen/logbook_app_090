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

  String selectedCategory = "Pribadi";

  /// TASK 5 PRIVACY
  bool isPublic = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.log?.title ?? "");

    _descController = TextEditingController(
      text: widget.log?.description ?? "",
    );

    /// set kategori jika edit
    if (widget.log != null) {
      selectedCategory = widget.log!.category;
      isPublic = widget.log!.isPublic;
    }

    /// agar preview update otomatis
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
        selectedCategory,
        "user_001",
        "team_001",
        isPublic,
      );

    } else {

      /// UPDATE
      await widget.controller.updateLog(
        widget.log!,
        _titleController.text,
        _descController.text,
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
    return DefaultTabController(
      length: 2,

      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),

          bottom: const TabBar(
            tabs: [
              Tab(text: "Editor"),
              Tab(text: "Pratinjau"),
            ],
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.save),
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
                children: [

                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Judul"),
                  ),

                  const SizedBox(height: 10),

                  /// DROPDOWN KATEGORI
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: "Kategori"),
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

                  const SizedBox(height: 10),

                  /// PRIVACY SWITCH (TASK 5)
                  SwitchListTile(
                    title: const Text("Public"),
                    subtitle: const Text(
                        "Jika aktif, anggota tim dapat melihat catatan ini"),
                    value: isPublic,
                    onChanged: (value) {
                      setState(() {
                        isPublic = value;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: "Tulis laporan dengan Markdown...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// TAB PREVIEW MARKDOWN
            Markdown(
              data: _descController.text,
            ),
          ],
        ),
      ),
    );
  }
}