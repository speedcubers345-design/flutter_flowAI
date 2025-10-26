// lib/widgets/focus_timer.dart

import 'dart:async';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/task_provider.dart';

class FocusTimer extends StatefulWidget {
  const FocusTimer({super.key});

  @override
  _FocusTimerState createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> {
  // --- Timer State ---
  static const int _initialDuration = 25 * 60; // 25 minutes in seconds
  int _currentDuration = _initialDuration;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  // --- Timer Logic ---
  void _startTimer() {
    if (_isRunning) return; // Don't start if already running

    // Create a periodic timer that ticks every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentDuration > 0) {
          _currentDuration--;
        } else {
          // Timer finished
          _timer?.cancel();
          _isRunning = false;
          _onTimerEnd();
        }
      });
    });

    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;

    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _currentDuration = _initialDuration;
      _isRunning = false;
    });
  }

  void _onTimerEnd() {
    // Log the completed session using the provider
    Provider.of<TaskProvider>(context, listen: false).logFocusSession();

    // Show a notification/alert
    if (!kIsWeb) {
      // We will add local notifications later.
      // For now, just print to console.
      print("Focus session complete! (Mobile notification would show here)");
    } else {
      // Show a simple web alert
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Focus Session Complete!"),
          content: const Text("Great job! You've completed a 25-minute focus session."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
    
    // Reset the timer for the next session
    _resetTimer();
  }

  // --- Helper to format time as MM:SS ---
  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainingSeconds";
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          children: [
            Text(
              "Focus Timer",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // The timer display
            Text(
              _formatDuration(_currentDuration),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace', // Gives a nice digital clock feel
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            // Timer control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reset Button
                IconButton(
                  icon: const Icon(Icons.refresh, size: 30),
                  onPressed: _resetTimer,
                  color: Colors.grey[600],
                ),
                // Start/Pause Button
                FloatingActionButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  elevation: 2,
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: 40,
                  ),
                ),
                // Placeholder for alignment
                const SizedBox(width: 48), // Match IconButton size
              ],
            ),
          ],
        ),
      ),
    );
  }
}