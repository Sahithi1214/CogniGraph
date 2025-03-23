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

  static const String _endpoint =
      'https://language.googleapis.com/v1/documents:analyzeEntities';

  static Future<List<String>> analyzeText(String text) async {
    final response = await http.post(
      Uri.parse('$_endpoint?key=AIzaSyDfd8gynHgKyd5TrolVreYeg3HIZp05yKA'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "document": {"type": "PLAIN_TEXT", "content": text},
        "encodingType": "UTF8"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final entities = data['entities'] as List;
      return entities.map((e) => e['name'].toString()).toList();
    } else {
      throw Exception("Failed to analyze text");
    }
  }

  // Google Books API base URL
  static const String _googleBooksBaseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // Method to fetch books based on the user's topics
  static Future<List<String>> fetchBooks(String query) async {
    final url = Uri.parse('$_googleBooksBaseUrl?q=$query&maxResults=5');  // Adjust maxResults as needed

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> books = [];

        // Parse the results and extract book titles and links
        for (var item in data['items']) {
          String title = item['volumeInfo']['title'];
          String link = item['volumeInfo']['infoLink'];
          books.add('$title: $link');
        }
        return books;
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

}
