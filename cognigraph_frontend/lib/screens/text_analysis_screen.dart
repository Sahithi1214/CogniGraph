import 'package:flutter/material.dart';
import '../api_service.dart';
import '../youtube_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class TextAnalysisScreen extends StatefulWidget {
  @override
  _TextAnalysisScreenState createState() => _TextAnalysisScreenState();
}

class _TextAnalysisScreenState extends State<TextAnalysisScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  List<String> _topics = [];
  List<String> _videoUrls = [];
  List<String> _bookUrls = [];
  late TabController _tabController;
  bool _showResults = false;
  List<String> _learningPath = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _analyzeText() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter some text to analyze')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _topics = [];
      _videoUrls = [];
      _bookUrls = [];
      _showResults = false;
    });

    try {
      // Fetch topics from Google NLP
      final topics = await ApiService.analyzeText(_textController.text);

      // Fetch YouTube videos based on topics
      final youtubeService = YouTubeAPIService();
      List<String> videoUrls = [];
      for (var topic in topics) {
        videoUrls.addAll(await youtubeService.searchVideos(topic));
      }

      // Fetch books based on topics
      List<String> bookUrls = [];
      for (var topic in topics) {
        final books = await ApiService.fetchBooks(topic);
        bookUrls.addAll(books);
      }

      setState(() {
        _topics = topics;
        _videoUrls = videoUrls;
        _bookUrls = bookUrls;
        _showResults = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Failed to analyze text'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Knowledge Explorer',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF121212),
              Color(0xFF1E1E1E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intro text
                if (!_showResults) ...[
                  Text(
                    'Discover Learning Resources',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter any text, article, or notes to extract key topics and find relevant learning materials.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 24),
                ],
                
                // Text input field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Paste your article, notes, or any text here...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      suffixIcon: _textController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.white38),
                              onPressed: () {
                                setState(() {
                                  _textController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    style: TextStyle(color: Colors.white),
                    maxLines: _showResults ? 3 : 8,
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(height: 16),
                
                // Analyze button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _analyzeText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF424242),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Analyze Content',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                
                // Results section
                if (_showResults && _topics.isNotEmpty) ...[
                  SizedBox(height: 24),
                  
                  // Key topics section
                  Text(
                    'Key Topics Identified',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  // Topic chips
                  Container(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _topics.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(_topics[index]),
                            backgroundColor: Color(0xFF424242),
                            labelStyle: TextStyle(color: Colors.white),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Tab bar for resources
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Color(0xFF757575),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      tabs: [
                        Tab(
                          icon: Icon(Icons.topic),
                          text: 'Topics',
                        ),
                        Tab(
                          icon: Icon(Icons.video_library),
                          text: 'Videos',
                        ),
                        Tab(
                          icon: Icon(Icons.book),
                          text: 'Books',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Topics tab
                        _buildTopicsTab(),
                        
                        // Videos tab
                        _buildVideosTab(),
                        
                        // Books tab
                        _buildBooksTab(),
                      ],
                    ),
                  ),
                ],
                
                // Loading indicator (when no results yet)
                if (_isLoading && !_showResults)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Analyzing your content...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _showResults
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showResults = false;
                });
              },
              backgroundColor: Color(0xFF424242),
              child: Icon(Icons.edit),
            )
          : null,
    );
  }

Widget _buildTopicsTab() {
  return _topics.isEmpty
      ? _buildEmptyState('No topics identified')
      : ListView.builder(
          itemCount: _topics.length,
          itemBuilder: (context, index) {
            return Card(
              color: Color(0xFF1E1E1E),
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF757575),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  _topics[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  'Tap to add to your learning path',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                onTap: () {
                  _addTopicToLearningPath(_topics[index]);
                  _saveTopicToMongoDB(_topics[index]);
                },
              ),
            );
          },
        );
}

void _addTopicToLearningPath(String topic) {
  setState(() {
    _learningPath.add(topic); // Add topic to the local learning path list
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '$topic added to your learning path',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color(0xFF424242),
    ),
  );
}

Future<void> _saveTopicToMongoDB(String topicName) async {
  try {
    await ApiService.addTopic(topicName);  // Call the addTopic method to save to MongoDB
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Topic saved to MongoDB',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF424242),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to save topic to MongoDB',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFd32f2f),
      ),
    );
  }
}



  Widget _buildVideosTab() {
    return _videoUrls.isEmpty
        ? _buildEmptyState('No videos found')
        : ListView.builder(
            itemCount: _videoUrls.length,
            itemBuilder: (context, index) {
              return Card(
                color: Color(0xFF1E1E1E),
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.red,
                    ),
                  ),
                  title: Text(
                    'Learning Video ${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    _videoUrls[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.open_in_new,
                    color: Colors.white60,
                  ),
                  onTap: () => _launchURL(_videoUrls[index]),
                ),
              );
            },
          );
  }

  Widget _buildBooksTab() {
    return _bookUrls.isEmpty
        ? _buildEmptyState('No books found')
        : ListView.builder(
            itemCount: _bookUrls.length,
            itemBuilder: (context, index) {
              return Card(
                color: Color(0xFF1E1E1E),
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.book,
                      color: Colors.blue,
                    ),
                  ),
                  title: Text(
                    'Book Resource ${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    _bookUrls[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.open_in_new,
                    color: Colors.white60,
                  ),
                  onTap: () => _launchURL(_bookUrls[index]),
                ),
              );
            },
          );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white24,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open the link'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}