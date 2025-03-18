import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';

class LearningPathScreen extends StatefulWidget {
  @override
  _LearningPathScreenState createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      await Provider.of<UserData>(context, listen: false).fetchTopics();
    } catch (e) {
      print("Error loading topics: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Learning Path')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learning Topics:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  userData.learningTopics.isEmpty
                      ? Text('No topics added yet.')
                      : Expanded(
                          child: ListView.builder(
                            itemCount: userData.learningTopics.length,
                            itemBuilder: (context, index) {
                              final topic = userData.learningTopics[index];
                              return ListTile(
                                title: Text(topic.topicName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LinearProgressIndicator(
                                      value: topic.progress / 100,
                                      minHeight: 8,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      topic.isCompleted
                                          ? 'Completed'
                                          : 'In Progress: ${topic.progress.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                          color: topic.isCompleted
                                              ? Colors.green
                                              : Colors.orange),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(topic.isCompleted
                                      ? Icons.check_circle
                                      : Icons.circle_outlined),
                                  onPressed: () {
                                    if (!topic.isCompleted) {
                                      userData.markCompleted(topic.topicName);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await userData.addTopic('Flutter Basics');
                    },
                    child: Text('Add Flutter Topic'),
                  ),
                ],
              ),
            ),
    );
  }
}


