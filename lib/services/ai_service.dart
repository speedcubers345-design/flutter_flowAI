// lib/services/ai_service.dart

import '../models/task.dart';

class AIService {
  // Generates a productivity suggestion based on the current task list
  String generateSuggestion(List<Task> tasks) {
    // 1. Filter tasks into different categories
    final now = DateTime.now();
    final incompleteTasks =
        tasks.where((task) => !task.isCompleted).toList();
    
    // Create a "clean" date for today (without time) for accurate comparison
    final today = DateTime(now.year, now.month, now.day);
    
    final overdueTasks = incompleteTasks
        .where((task) => task.dueDate.isBefore(today))
        .toList();

    // 2. Apply rules to generate suggestions
    
    // Rule: High-priority warning for overdue tasks
    if (overdueTasks.length >= 3) {
      return "You have ${overdueTasks.length} overdue tasks! 🚨 Focus on completing these high-priority items first.";
    }

    // Rule: Warning for a high number of pending tasks
    if (incompleteTasks.length >= 7) {
      return "You have ${incompleteTasks.length} pending tasks. Try breaking them down and start a focus session to get ahead!";
    }
    
    // Rule: Gentle nudge for a few pending tasks
    if (incompleteTasks.length >= 3) {
      return "Keep up the momentum! You have a few tasks left. Pick one and get started.";
    }

    // Rule: All tasks are completed
    if (incompleteTasks.isEmpty && tasks.isNotEmpty) {
      return "Amazing work! 🎉 All your tasks are complete. Time to relax or plan your next big goal.";
    }

    // Rule: No tasks at all
    if (tasks.isEmpty) {
      return "Ready to be productive? Add your first task to get started!";
    }

    // Default motivational message
    return "Keep up the great work! Every step, no matter how small, is progress. 💪";
  }
}