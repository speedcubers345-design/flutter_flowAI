// lib/providers/task_provider.dart

import 'dart:async';

// --- CORRECTED IMPORTS ---
import 'package:flutter/foundation.dart'; // This was the broken line
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/firebase_service.dart';
// -------------------------

class TaskProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = Uuid();

  List<Task> _tasks = [];
  bool _isLoading = true;
  StreamSubscription? _tasksSubscription;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    // Immediately start listening for tasks when the provider is created
    fetchTasks();
  }

  // Get all tasks from Firebase and listen for real-time updates
  void fetchTasks() {
    _isLoading = true;
    notifyListeners();

    // Cancel any existing subscription to avoid memory leaks
    _tasksSubscription?.cancel();

    _tasksSubscription = _firebaseService.getTasks().listen((tasks) {
      _tasks = tasks;
      _isLoading = false;

      // Sort tasks: incomplete first, then by due date
      _tasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.dueDate.compareTo(b.dueDate);
      });

      notifyListeners();
    }, onError: (error) {
      print("Error fetching tasks: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  // Add a new task
  Future<void> addTask({
    required String title,
    required String description,
    required TaskCategory category,
    required DateTime dueDate,
  }) async {
    try {
      final newTask = Task(
        id: _uuid.v4(), // Generate a unique ID
        title: title,
        description: description,
        category: category,
        dueDate: dueDate,
        isCompleted: false,
      );
      await _firebaseService.addTask(newTask);
      // No need to call notifyListeners() here, as the stream
      // from getTasks() will automatically update the list.
    } catch (e) {
      print("Error adding task in provider: $e");
    }
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      await _firebaseService.updateTask(task);
    } catch (e) {
      print("Error updating task in provider: $e");
    }
  }

  // Toggle the completion status of a task
  Future<void> toggleTaskCompletion(Task task) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await _firebaseService.updateTask(updatedTask);
    } catch (e) {
      print("Error toggling task completion: $e");
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firebaseService.deleteTask(taskId);
    } catch (e) {
      print("Error deleting task in provider: $e");
    }
  }

  // Log a focus session
  Future<void> logFocusSession() async {
    try {
      await _firebaseService.logFocusSession();
      print("Focus session logged successfully.");
    } catch (e) {
      print("Error logging focus session in provider: $e");
    }
  }

  // Clean up the stream subscription when the provider is disposed
  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}