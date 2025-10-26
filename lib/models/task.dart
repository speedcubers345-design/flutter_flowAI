// lib/models/task.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum for task categories
enum TaskCategory {
  work,
  study,
  personal,
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final DateTime dueDate;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    this.isCompleted = false,
  });

  // Helper method to convert Task to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      // Store category as a string
      'category': category.name, 
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
    };
  }

  // Helper method to create Task from a Firestore DocumentSnapshot
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Task(
      id: data['id'] ?? doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      // Convert string back to enum
      category: TaskCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => TaskCategory.personal, // Default value
      ),
      // Convert Firestore Timestamp to DateTime
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  // Helper method to create a copy of a Task with some fields updated
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}