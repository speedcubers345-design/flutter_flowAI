// lib/screens/add_task_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../provider/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  // This optional task is passed in when editing an existing task
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers and state
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime _dueDate = DateTime.now();
  TaskCategory _selectedCategory = TaskCategory.personal;

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();

    // Pre-populate fields if we are in "edit" mode
    if (_isEditing) {
      _titleController = TextEditingController(text: widget.taskToEdit!.title);
      _descriptionController =
          TextEditingController(text: widget.taskToEdit!.description);
      _dueDate = widget.taskToEdit!.dueDate;
      _selectedCategory = widget.taskToEdit!.category;
    } else {
      // Otherwise, initialize as empty
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Date Picker Logic ---
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  // --- Form Submission Logic ---
  void _submitForm() {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (_isEditing) {
        // --- Update Existing Task ---
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          dueDate: _dueDate,
        );
        taskProvider.updateTask(updatedTask);
      } else {
        // --- Add New Task ---
        taskProvider.addTask(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          dueDate: _dueDate,
        );
      }

      // Close the screen after saving
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Task" : "Add New Task"),
        backgroundColor: Theme.of(context).primaryColorLight,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Title Field ---
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Task Title",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- Description Field ---
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description (Optional)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // --- Category Dropdown ---
                DropdownButtonFormField<TaskCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: TaskCategory.values.map((TaskCategory category) {
                    return DropdownMenuItem<TaskCategory>(
                      value: category,
                      child: Text(
                          category.name[0].toUpperCase() + category.name.substring(1)),
                    );
                  }).toList(),
                  onChanged: (TaskCategory? newValue) {
                    setState(() {
                      if (newValue != null) {
                        _selectedCategory = newValue;
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),

                // --- Date Picker ---
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Due Date: ${DateFormat.yMMMd().format(_dueDate)}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit_calendar_outlined),
                      label: const Text("Change"),
                      onPressed: () => _pickDate(context),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // --- Submit Button ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(_isEditing ? "Save Changes" : "Add Task"),
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}