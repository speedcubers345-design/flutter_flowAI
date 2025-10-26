// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'provider/task_provider.dart';
import 'screens/home_screen.dart';

// --- IMPORTANT: ADD YOUR FIREBASE CONFIG HERE ---
// Copy this from your Firebase project settings (Step 2 in our setup)
const firebaseOptions = FirebaseOptions (
  apiKey: "AIzaSyCGv78-vV8lmyxA0oHlVlmR5-O3VzvQBtg",
  authDomain: "zwight-61nyi2.firebaseapp.com",
  projectId: "zwight-61nyi2",
  storageBucket: "zwight-61nyi2.firebasestorage.app",
  messagingSenderId: "1024299918571",
  appId: "1:1024299918571:web:13d060a08a9fd96ccf4aae"
);
// -------------------------------------------------

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: firebaseOptions,
  );
  
  // Run the app
  runApp(const FlowAIApp());
}

class FlowAIApp extends StatelessWidget {
  const FlowAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use ChangeNotifierProvider to create and provide the TaskProvider
    // to the entire widget tree below it.
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'FlowAI',
        theme: ThemeData(
          // Define a modern color scheme
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue[600],
          primaryColorLight: Colors.blue[50],
          
          // Define a modern app bar theme
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[50],
            foregroundColor: Colors.black87,
            elevation: 1,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          // Define a theme for the floating action button
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
          
          // Define a theme for the bottom navigation bar
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.blue[600],
            unselectedItemColor: Colors.grey[600],
          ),
          
          // Define a theme for cards
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        // The main screen of the app
        home: const HomeScreen(),
      ),
    );
  }
}