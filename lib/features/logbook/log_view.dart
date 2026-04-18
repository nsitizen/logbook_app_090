import 'package:flutter/material.dart';
import 'package:logbook_app_090/features/onboarding/onboarding_view.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'package:intl/intl.dart';
import 'log_editor_page.dart';
import 'package:logbook_app_090/features/vision/vision_view.dart';

class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {

  final LogController _controller = LogController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  final List<String> _categories = [
    "All",
    "Mechanical",
    "Electronic",
    "Software",
  ];
  final String teamId = "team_001";

  @override
  void initState() {
    super.initState();

    _controller.setUser(widget.username);
    _controller.startConnectivityListener();
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
        builder: (context) => LogEditorPage(log: log, controller: _controller),
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
                    color: online ? Colors.green : Colors.grey,
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
                  title: Text(
                    "Konfirmasi Logout",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  content: Text(
                    "Apakah Anda yakin?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Catat aktivitas harianmu hari ini ✨",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
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

          /// FILTER CATEGORY (HORIZONTAL CHIP)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Colors.deepPurpleAccent,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          /// LIST LOG
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, logs, _) {

                /// PRIVACY FILTER
                final displayLogs = logs.where((log) {
                  final isOwner = log.authorId == _controller.userId;

                  final passPrivacy = isOwner || log.isPublic == true;

                  final passCategory = _selectedCategory == "All"
                      ? true
                      : log.category == _selectedCategory;

                  return passPrivacy && passCategory;
                }).toList();

                final isSearching = _searchController.text.isNotEmpty;

                if (displayLogs.isEmpty) {
                  if (isSearching) {

                    /// EMPTY SEARCH RESULT
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

                          Text(
                            "Tidak ada catatan yang anda cari.",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {

                    /// NO DATA AT ALL
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

                          Text(
                            "Belum ada aktivitas hari ini",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Mulai catat aktivitas Anda!",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await _controller.loadLogs(teamId);
                  },
                  child: ListView.builder(
                    itemCount: displayLogs.length,
                    itemBuilder: (context, index) {
                      final log = displayLogs[index];

                      final bool isOwner = log.authorId == _controller.userId;

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
                                "Apakah Anda yakin ingin menghapus catatan ini?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// DESCRIPTION
                                Text(
                                  log.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),

                                const SizedBox(height: 8),

                                /// CATEGORY
                                Chip(
                                  label: Text(
                                    log.category,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  backgroundColor: Colors.white,
                                  avatar: Icon(
                                    _getCategoryIcon(log.category),
                                    size: 16,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                /// DATE
                                Text(
                                  _formatDate(log.date),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),

                            trailing: isOwner
                                ? SizedBox(
                                    width: 96,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () =>
                                              _goToEditor(log: log),
                                        ),

                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            await _controller.removeLog(log);

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Catatan berhasil dihapus ✅",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
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

      floatingActionButton: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.filteredLogs,
        builder: (context, logs, _) {
          final displayLogs = logs.where((log) {
            final isOwner = log.authorId == _controller.userId;

            final passPrivacy = isOwner || log.isPublic == true;

            final passCategory = _selectedCategory == "All"
                ? true
                : log.category == _selectedCategory;

            return passPrivacy && passCategory;
          }).toList();

          if (displayLogs.isEmpty) {
            return const SizedBox(); 
          }

          /// Tampilkan kalau ada data
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 1. Tombol Kamera Baru (Vision)
              FloatingActionButton(
                heroTag: "btn_vision", // heroTag wajib diisi jika ada >1 FAB di satu halaman
                backgroundColor: Colors.orangeAccent, 
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VisionView(),
                    ),
                  );
                },
                child: const Icon(Icons.camera_alt),
              ),
              
              const SizedBox(height: 16), // Jarak antar tombol
              
              // 2. Tombol Tambah Catatan yang Lama
              FloatingActionButton(
                heroTag: "btn_add_log",
                backgroundColor: Colors.deepPurpleAccent,
                onPressed: () => _goToEditor(),
                child: const Icon(Icons.add),
              ),
            ],
          );
        },
      ),
    );
  }
}
