// lib/services/firebase_service.dart

// --- CORRECTED IMPORTS ---
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
// -------------------------

class FirebaseService {
  // Get a reference to the 'tasks' collection in Firestore
  // We'll add a 'users' collection later if auth is implemented.
  // For now, we use a single 'tasks' collection for simplicity.
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  // Get a reference to the 'analytics' collection
  final CollectionReference _analyticsCollection =
      FirebaseFirestore.instance.collection('analytics');

  // --- Task Methods ---

  // Create a new task
  Future<void> addTask(Task task) async {
    try {
      await _tasksCollection.doc(task.id).set(task.toMap());
    } catch (e) {
      print("Error adding task: $e");
      // Re-throw the error to be handled by the provider
      rethrow;
    }
  }

  // Read tasks from Firestore
  Stream<List<Task>> getTasks() {
    return _tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      await _tasksCollection.doc(task.id).update(task.toMap());
    } catch (e) {
      print("Error updating task: $e");
      rethrow;
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      print("Error deleting task: $e");
      rethrow;
    }
  }

  // --- Analytics Methods ---

  // Log a completed Pomodoro session
  Future<void> logFocusSession() async {
    final today = DateTime.now();
    // Using 'yyyy-MM-dd' as the document ID for daily tracking
    final docId =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final docRef = _analyticsCollection.doc(docId);

    try {
      // Use a transaction to safely increment the count
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          // If no document exists for today, create one
          transaction.set(docRef, {
            'date': Timestamp.fromDate(today),
            'completedSessions': 1,
          });
        } else {
          // If it exists, increment the session count
          final newCount = (snapshot.data()
                  as Map<String, dynamic>)['completedSessions'] +
              1;
          transaction.update(docRef, {'completedSessions': newCount});
        }
      });
    } catch (e) {
      print("Error logging focus session: $e");
      rethrow;
    }
  }

  // Stream analytics data for charts
  Stream<QuerySnapshot> getAnalytics() {
    // Get analytics for the last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _analyticsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('date', descending: true)
        .snapshots();
  }
}