// lib/screens/home_screen.dart

// --- ALL IMPORTS FIXED ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/focus_timer.dart';
import 'add_task_screen.dart';
import 'analytics_screen.dart';
import 'ai_suggestion_widget.dart';
// -------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0: Tasks, 1: Focus, 2: Analytics

  // This list holds the main content widget for each tab
  static final List<Widget> _widgetOptions = <Widget>[
    const _TaskListTab(), // Tab 0
    const _FocusTimerTab(), // Tab 1
    const AnalyticsScreen(), // Tab 2 (This might still show a ghost error)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FlowAI Coach"),
        backgroundColor: Theme.of(context).primaryColorLight,
        // We'll show the analytics icon only if not on the analytics tab
        actions: [
          if (_selectedIndex != 2)
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () => _onItemTapped(2), // Switch to Analytics
            ),
        ],
      ),
      // Display the selected tab's widget
      body: _widgetOptions.elementAt(_selectedIndex),

      // Floating action button to add tasks (only shows on the Tasks tab)
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTaskScreen(),
                  ),
                );
              },
              tooltip: "Add Task",
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Analytics',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- TASKS TAB ---
// We create a separate widget for the Tasks tab to keep the build method clean
class _TaskListTab extends StatelessWidget {
  const _TaskListTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the provider to listen for changes to the task list
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (taskProvider.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AiSuggestionWidget(), // Show AI suggestion
                const SizedBox(height: 20),
                const Text(
                  "No tasks yet. Add one to get started!",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Build the list
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // Avoid FAB
          itemCount: taskProvider.tasks.length + 1, // +1 for the AI widget
          itemBuilder: (context, index) {
            if (index == 0) {
              // Show the AI suggestion at the top
              return AiSuggestionWidget();
            }
            // The actual task tile
            final task = taskProvider.tasks[index - 1];
            return TaskTile(task: task);
          },
        );
      },
    );
  }
}

// --- FOCUS TAB ---
// A simple wrapper for the FocusTimer widget
class _FocusTimerTab extends StatelessWidget {
  const _FocusTimerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        child: FocusTimer(),
      ),
    );
  }
}