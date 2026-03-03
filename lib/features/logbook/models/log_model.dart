import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? id;
  final String title;
  final String description;
  final String date;
  final String category;

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
  });

  /// 🔄 Dari MongoDB (BSON) → Object Flutter
  factory LogModel.fromMap(Map<String, dynamic> map) {
    ObjectId? parsedId;

    if (map['_id'] != null) {
      if (map['_id'] is ObjectId) {
        parsedId = map['_id'];
      } else if (map['_id'] is String) {
        parsedId = ObjectId.fromHexString(map['_id']);
      }
    }

    return LogModel(
      id: parsedId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      category: map['category'] ?? 'Pribadi',
    );
  }

  /// 📦 Dari Object Flutter → BSON
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'date': date,
      'category': category,
    };

    // hanya kirim _id kalau memang ada
    if (id != null) {
      map['_id'] = id;
    }

    return map;
  }
}
