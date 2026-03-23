import 'package:flutter/material.dart';
import 'package:logbook_app_090/features/onboarding/onboarding_view.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'package:intl/intl.dart';
import 'log_editor_page.dart';

class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  final TextEditingController _searchController = TextEditingController();

  final String teamId = "team_001";

  @override
  void initState() {
    super.initState();

    /// LOAD DATA (Offline First)
    _controller.loadLogs(teamId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToEditor({LogModel? log}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          controller: _controller,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Mechanical":
        return Colors.green.shade100;

      case "Electronic":
        return Colors.blue.shade100;

      case "Software":
        return Colors.orange.shade100;

      default:
        return Colors.grey.shade200;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Mechanical":
        return Icons.precision_manufacturing;

      case "Electronic":
        return Icons.memory;

      case "Software":
        return Icons.code;

      default:
        return Icons.notes;
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return "${difference.inSeconds} detik yang lalu";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes} menit yang lalu";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} jam yang lalu";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} hari yang lalu";
      } else {
        return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E7FF),

      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          "Logbook: ${widget.username}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _controller.isSyncing,
            builder: (context, syncing, _) {

              if (syncing) {

                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                );

              }

              return ValueListenableBuilder<bool>(
                valueListenable: _controller.isOnline,
                builder: (context, online, _) {

                  return Icon(
                    online ? Icons.cloud_done : Icons.cloud_off,
                    color: online ? Colors.green : Colors.red,
                  );

                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF3E7FF)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi Logout"),
                  content: const Text("Apakah Anda yakin?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingView(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Ya, Keluar",
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

      body: Column(
        children: [

          /// HEADER
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.purple],
              ),
              borderRadius: BorderRadius.circular(20),
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
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _controller.searchLog(value),
              decoration: const InputDecoration(
                labelText: "Cari Catatan...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          /// LIST LOG
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, logs, _) {

                /// =========================
                /// PRIVACY FILTER (TASK 5)
                /// =========================

                final displayLogs = logs.where((log) {

                  final isOwner = log.authorId == _controller.userId;

                  return isOwner || log.isPublic == true;

                }).toList();

                if (displayLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Icon(
                          Icons.auto_stories,
                          size: 80,
                          color: Colors.deepPurple.shade200,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Belum ada aktivitas hari ini",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Mulai catat kemajuan proyek Anda!",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed: () => _goToEditor(),
                          icon: const Icon(Icons.add),
                          label: const Text("Tambah Catatan"),
                        )
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await _controller.loadLogs(teamId);
                  },
                  child: ListView.builder(
                    itemCount: displayLogs.length,
                    itemBuilder: (context, index) {

                      final log = displayLogs[index];

                      final bool isOwner =
                          log.authorId == _controller.userId;

                      return Dismissible(
                        key: Key(log.id ?? log.date),

                        /// OWNER ONLY DELETE
                        direction: isOwner
                            ? DismissDirection.endToStart
                            : DismissDirection.none,

                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),

                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Hapus Catatan"),
                              content: const Text(
                                  "Apakah Anda yakin ingin menghapus catatan ini?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },

                        onDismissed: (direction) async {

                          await _controller.removeLog(log);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Catatan berhasil dihapus ✅"),
                            ),
                          );
                        },

                        child: Card(
                          elevation: 8,
                          color: _getCategoryColor(log.category),

                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      avatar: Icon(
                                        _getCategoryIcon(log.category),
                                        size: 16,
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

                                /// EDIT (OWNER ONLY)
                                if (isOwner)
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _goToEditor(log: log),
                                  ),

                                /// DELETE (OWNER ONLY)
                                if (isOwner)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {

                                      await _controller.removeLog(log);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Catatan berhasil dihapus ✅"),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () => _goToEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}