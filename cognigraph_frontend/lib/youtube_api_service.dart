import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeAPIService {
  final String apiKey = 'AIzaSyDfd8gynHgKyd5TrolVreYeg3HIZp05yKA';  // Replace with your API key

  Future<List<String>> searchVideos(String query) async {
    final url = Uri.parse('https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<String> videoUrls = [];

      for (var item in data['items']) {
        String videoId = item['id']['videoId'];
        String videoUrl = 'https://www.youtube.com/watch?v=$videoId';
        videoUrls.add(videoUrl);
      }

      return videoUrls;
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
