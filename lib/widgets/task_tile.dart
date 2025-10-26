// lib/widgets/task_tile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// --- CORRECTED IMPORTS (using relative paths) ---
import '../models/task.dart';
import '../provider/task_provider.dart';
import '../screens/add_task_screen.dart'; // This file doesn't exist yet, so the error is OK.
// --------------------------------------------------

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  // Helper method to get the color for each category
  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue[400]!;
      case TaskCategory.study:
        return Colors.orange[400]!;
      case TaskCategory.personal:
        return Colors.green[400]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the provider to call methods (but don't listen to changes here)
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Format the due date for display
    final formattedDate = DateFormat.yMMMd().format(task.dueDate);

    // Check if the task is overdue
    final bool isOverdue =
        !task.isCompleted && task.dueDate.isBefore(DateTime.now());

    return Dismissible(
      key: Key(task.id), // Unique key for the dismissible item
      direction: DismissDirection.endToStart,
      // Confirmation dialog before deleting
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Delete"),
              content: const Text("Are you sure you want to delete this task?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("DELETE"),
                ),
              ],
            );
          },
        );
      },
      // Action to perform after dismissal
      onDismissed: (direction) {
        taskProvider.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${task.title} deleted"),
            backgroundColor: Colors.red,
          ),
        );
      },
      // Background shown when swiping
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      // The actual content of the list tile
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          // Checkbox to mark as complete
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) {
              taskProvider.toggleTaskCompletion(task);
            },
            activeColor: _getCategoryColor(task.category),
          ),
          // Task title
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Due date and category
          subtitle: Row(
            children: [
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(task.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.category.name.toUpperCase(),
                  style: TextStyle(
                    color: _getCategoryColor(task.category),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Due date
              Icon(
                Icons.calendar_today,
              size: 12,
        color: isOverdue ? Colors.red : Colors.grey[600],
      ), // Icon
            ],
          ),
          // Edit button
          trailing: IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
            onPressed: () {
              // Navigate to the AddTaskScreen in 'edit' mode
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(taskToEdit: task),
                ),
              );
            },
          ),
        ),
     ), // Card
     ); // Dismissible
  } // Closes the 'build' method
} // Closes the 'TaskTile' classld method