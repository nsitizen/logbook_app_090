class LogModel {
  final String title;
  final String description;
  final String date;

  LogModel({
    required this.title,
    required this.description,
    required this.date,
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'],
      description: map['description'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
    };
  }
}