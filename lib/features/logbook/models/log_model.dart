import 'package:mongo_dart/mongo_dart.dart';
import 'package:hive/hive.dart';

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final String type;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final String authorId;

  @HiveField(7)
  final bool isPublic;

  @HiveField(8)
  final String teamId;

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.category,
    required this.authorId,
    required this.teamId,
    this.isPublic = false,
  });

  /// =============================
  /// FROM MONGODB → OBJECT
  /// =============================
  factory LogModel.fromMap(Map<String, dynamic> map) {
    String? parsedId;

    if (map['_id'] != null) {
      if (map['_id'] is ObjectId) {
        parsedId = map['_id'].toHexString();
      } else if (map['_id'] is String) {
        parsedId = map['_id'];
      }
    }

    return LogModel(
      id: parsedId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      type: map['type'] ?? 'Pribadi',
      category: map['category'] ?? 'Mechanical',
      authorId: map['authorId'] ?? 'unknown_user',
      teamId: map['teamId'] ?? 'no_team',
    );
  }

  /// =============================
  /// OBJECT → MONGODB MAP
  /// =============================
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'date': date,
      'type': type,
      'category': category,
      'authorId': authorId,
      'teamId': teamId,
    };

    if (id != null) {
      map['_id'] = ObjectId.fromHexString(id!);
    }

    return map;
  }
}
