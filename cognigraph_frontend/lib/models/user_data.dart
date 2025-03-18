import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LearningTopic {
  String topicName;
  bool isCompleted;
  double progress;

  LearningTopic({
    required this.topicName,
    this.isCompleted = false,
    this.progress = 0.0,
  });

  // Factory method to create a LearningTopic from JSON
  factory LearningTopic.fromJson(Map<String, dynamic> json) {
    return LearningTopic(
      topicName: json['topicName'],
      isCompleted: json['isCompleted'] ?? false,
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'topicName': topicName,
      'isCompleted': isCompleted,
      'progress': progress,
    };
  }
}

class UserData extends ChangeNotifier {
  String userName = "John Doe";
  List<String> preferences = [];
  List<LearningTopic> learningTopics = [];

  final String baseUrl = "http://localhost:3000/api";

  UserData() {
    fetchTopics();
  }

   // New method to update the username
  void updateUserName(String newName) {
    userName = newName;
    notifyListeners();
  }

  // New method to add a preference
  void addPreference(String preference) {
    if (!preferences.contains(preference)) {
      preferences.add(preference);
      notifyListeners();
    }
  }

  // New method to remove a preference
  void removePreference(String preference) {
    preferences.remove(preference);
    notifyListeners();
  }

  Future<void> fetchTopics() async {
    final response = await http.get(Uri.parse('$baseUrl/topics'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      learningTopics = data.map((e) => LearningTopic.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load topics');
    }
  }

  Future<void> addTopic(String topic) async {
    final newTopic = LearningTopic(topicName: topic);
    learningTopics.add(newTopic);
    notifyListeners();

    final response = await http.post(
      Uri.parse('$baseUrl/topics'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newTopic.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add topic');
    }
  }

  Future<void> removeTopic(String topic) async {
    learningTopics.removeWhere((t) => t.topicName == topic);
    notifyListeners();

    final response = await http.delete(Uri.parse('$baseUrl/topics/$topic'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete topic');
    }
  }

  Future<void> markCompleted(String topic) async {
    final topicToUpdate = learningTopics.firstWhere((t) => t.topicName == topic);
    topicToUpdate.isCompleted = true;
    topicToUpdate.progress = 100.0;
    notifyListeners();

    await updateTopic(topicToUpdate);
  }

  Future<void> updateProgress(String topic, double progress) async {
    final topicToUpdate = learningTopics.firstWhere((t) => t.topicName == topic);
    topicToUpdate.progress = progress;
    notifyListeners();

    await updateTopic(topicToUpdate);
  }

  Future<void> updateTopic(LearningTopic topic) async {
    final response = await http.put(
      Uri.parse('$baseUrl/topics/${topic.topicName}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(topic.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update topic');
    }
  }
}
