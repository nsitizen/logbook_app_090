import 'package:flutter/material.dart';
import 'package:logbook_app_090/features/onboarding/onboarding_view.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'package:intl/intl.dart';

class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = "Pribadi";

  final List<String> _categories = [
    "Pekerjaan",
    "Pribadi",
    "Urgent"
  ];

  @override
  void initState() {
    super.initState();
    _controller.loadFromDisk(widget.username);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Pekerjaan":
        return Colors.blue.shade100;
      case "Urgent":
        return Colors.red.shade100;
      default:
        return Colors.green.shade100;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Pekerjaan":
        return Icons.work;
      case "Urgent":
        return Icons.warning;
      default:
        return Icons.person;
    }
  }

  String _formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Catatan"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "Judul"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(hintText: "Deskripsi"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration:
                    const InputDecoration(labelText: "Kategori"),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isEmpty ||
                  _contentController.text.isEmpty) return;

              await _controller.addLog(
                widget.username,
                _titleController.text,
                _contentController.text,
                _selectedCategory,
              );

              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditLogDialog(int realIndex, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    _selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController),
              const SizedBox(height: 10),
              TextField(controller: _contentController),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration:
                    const InputDecoration(labelText: "Kategori"),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _controller.updateLog(
                widget.username,
                realIndex,
                _titleController.text,
                _contentController.text,
                _selectedCategory,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Catatan berhasil diperbarui ✨"),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E7FF),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text("Logbook: ${widget.username}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF3E7FF)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi Logout"),
                  content: const Text(
                      "Apakah Anda yakin?"),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const OnboardingView(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Ya, Keluar",
                        style:
                            TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.deepPurpleAccent,
                  Colors.purple,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, ${widget.username} 👋",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Catat aktivitas harianmu hari ini ✨",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  _controller.searchLog(value),
              decoration: const InputDecoration(
                labelText: "Cari Catatan...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable:
                  _controller.filteredLogs,
              builder: (context, logs, _) {
                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.menu_book,
                          size: 100,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Belum ada catatan 📝",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder:
                      (context, index) {
                    final log = logs[index];

                    final realIndex = _controller
                        .logsNotifier.value
                        .indexOf(log);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Dismissible(
                        key: Key(log.date),
                        direction:
                            DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment:
                              Alignment.centerRight,
                          padding:
                              const EdgeInsets.only(
                                  right: 20),
                          child: const Icon(
                              Icons.delete,
                              color: Colors.white),
                        ),
                        onDismissed:
                            (direction) async {
                          await _controller
                              .removeLog(
                                  widget.username,
                                  realIndex);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Catatan dihapus"),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 8,
                          shadowColor: Colors.deepPurple.withOpacity(0.2),
                          color:
                              _getCategoryColor(
                                  log.category),
                          margin:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: Icon(
                              _getCategoryIcon(log.category),
                              color: Colors.deepPurple,
                            ),
                            title: Text(
                              log.title,
                              style:
                                  const TextStyle(
                                      fontWeight:
                                          FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(log.description),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        log.category,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.deepPurple.shade200,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDate(log.date),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.edit,
                                      color:
                                          Colors.blue),
                                  onPressed: () =>
                                      _showEditLogDialog(
                                          realIndex,
                                          log),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Hapus Catatan"),
                                        content: const Text("Yakin ingin menghapus catatan ini?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Batal"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);

                                              await _controller.removeLog(widget.username, index);

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Catatan berhasil dihapus ✅"),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              "Hapus",
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            Colors.deepPurpleAccent,
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}