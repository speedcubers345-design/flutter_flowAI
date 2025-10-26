// lib/screens/ai_suggestion_widget.dart

// --- CORRECTED IMPORTS ---
import 'package:flutter/material.dart'; // Fixed the typo here
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../provider/task_provider.dart'; // Your folder is 'provider' (singular)
import '../services/ai_service.dart';
// -------------------------

class AiSuggestionWidget extends StatelessWidget {
  // Create a single instance of the AI service
  final AIService _aiService = AIService();

  AiSuggestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to listen for changes in the TaskProvider
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // Get the current list of tasks
        final List<Task> tasks = taskProvider.tasks;

        // Generate a new suggestion based on the current tasks
        final String suggestion = _aiService.generateSuggestion(tasks);

        // Build the suggestion card
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.blueGrey[50], // A light background color
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blueGrey[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                // Suggestion Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "FlowAI Coach",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey[700],
                          height: 1.4, // Improves readability
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}