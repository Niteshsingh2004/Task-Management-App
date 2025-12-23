import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    // Helper function to safely parse Date
    DateTime parseDate(dynamic dateVal) {
      if (dateVal is Timestamp) {
        return dateVal.toDate();
      } else if (dateVal is String) {
        return DateTime.tryParse(dateVal) ?? DateTime.now();
      } else {
        return DateTime.now(); // Agar null ho toh current time le lo
      }
    }

    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: parseDate(map['dueDate']),
      priority: map['priority'] ?? 'low',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
