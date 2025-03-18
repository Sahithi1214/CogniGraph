import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'models/user_data.dart'; // Import the UserData model
import 'screens/learning_path_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserData(), // Initialize the UserData model
      child: CogniGraphApp(),
    ),
  );
}

class CogniGraphApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CogniGraph',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CogniGraph Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to CogniGraph!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Your learning journey begins here. Track your progress and explore new topics.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to Learning Path Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LearningPathScreen()),
                );
              },
              child: Text('Explore Your Learning Path'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Profile & Settings Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Text('Profile & Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
