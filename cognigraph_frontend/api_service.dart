import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://localhost:3000/api";

  Future<List<Map<String, dynamic>>> fetchTopics() async {
    final response = await http.get(Uri.parse('$baseUrl/topics'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load topics');
    }
  }

  Future<void> addTopic(String topicName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/topics'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'topicName': topicName}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add topic');
    }
  }

  Future<void> updateTopic(String topicName, double progress, bool isCompleted) async {
    final response = await http.put(
      Uri.parse('$baseUrl/topics/$topicName'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'progress': progress, 'isCompleted': isCompleted}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update topic');
    }
  }
}
