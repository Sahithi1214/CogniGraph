import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';
import 'package:graphview/GraphView.dart';

class LearningPathScreen extends StatefulWidget {
  @override
  _LearningPathScreenState createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  late Graph graph;
  late Algorithm algorithm;
  bool isLoading = true;
  double _zoom = 1.0;
  
  // Controller for the interactive viewer
  final TransformationController _transformationController = TransformationController();
  
  @override
  void initState() {
    super.initState();
    graph = Graph();
    
    // Using SugiyamaAlgorithm with proper configuration
    algorithm = SugiyamaAlgorithm(
      SugiyamaConfiguration()
        ..nodeSeparation = 60
        ..levelSeparation = 100
        ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userData = Provider.of<UserData>(context, listen: false);
    //   await userData.fetchRecommendedTopics();
      await userData.fetchTopics();
      buildGraph(userData);
      setState(() {
        isLoading = false;
      });
    });
  }

  void buildGraph(UserData userData) {
    graph.nodes.clear();
    graph.edges.clear();
    
    // Create a mapping of topic names to nodes
    Map<String, Node> topicNodes = {};

    // Add current learning topics as nodes
    for (var topic in userData.learningTopics) {
      var node = Node.Id(topic);
      topicNodes[topic.topicName] = node;
      graph.addNode(node);
    }

    // Add recommended topics as separate nodes
    for (var topic in userData.recommendedTopics) {
      var node = Node.Id(topic);
      topicNodes[topic.topicName] = node;
      graph.addNode(node);
    }

    // Create edges based on topic relationships
    for (var topic in userData.learningTopics) {
      for (var related in topic.relatedTopics) {
        if (topicNodes.containsKey(related)) {
          graph.addEdge(topicNodes[topic.topicName]!, topicNodes[related]!);
        }
      }
    }

    // Connect recommended topics to relevant existing ones
    for (var topic in userData.recommendedTopics) {
      for (var related in topic.relatedTopics) {
        if (topicNodes.containsKey(related)) {
          graph.addEdge(topicNodes[topic.topicName]!, topicNodes[related]!);
        }
      }
    }
  }

  Widget _buildNodeWidget(Node node) {
    // Extract the topic object from the node
    final topic = node.key!.value as LearningTopic;
    final isRecommended = Provider.of<UserData>(context).recommendedTopics.contains(topic);
    
    return GestureDetector(
      onTap: () => _showTopicDetails(topic),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRecommended ? Colors.white70 : Colors.grey[700],
borderRadius: BorderRadius.circular(10),
boxShadow: [
  BoxShadow(
    color: Colors.black45,  // Darker shadow for a black-themed design
    blurRadius: 6,  // Slightly stronger blur effect for a more intense shadow
    offset: Offset(0, 2),
  ),
],
gradient: LinearGradient(
  colors: isRecommended
      ? [Colors.white24, Colors.black54]  // Lighter amber-like gradient
      : [Colors.grey[800]!, Colors.black],  // A grey to black gradient for a darker theme
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: topic.isCompleted ? Colors.green : Colors.grey.shade400,
            width: 2,
          ),
        ),
        constraints: BoxConstraints(
          minWidth: 100,
          maxWidth: 150,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              topic.topicName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: topic.progress / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                topic.progress > 0 ? Colors.green : Colors.blue,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "${topic.progress}%",
              style: TextStyle(fontSize: 12),
            ),
            if (topic.isCompleted)
              Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
      ),
    );
  }

  void _showTopicDetails(LearningTopic topic) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  topic.topicName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Progress: ${topic.progress.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: topic.progress / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 16),
            Text(
              'Related Topics:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topic.relatedTopics.map((related) {
                return Chip(
                  label: Text(related),
                  backgroundColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add to learning path or start learning
                Navigator.pop(context);
              },
              child: Text(topic.progress > 0 
                  ? 'Continue Learning' 
                  : 'Start Learning'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Learning Path'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Path'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add search functionality
              showSearch(
                context: context,
                delegate: TopicSearchDelegate(
                  allTopics: [...userData.learningTopics, ...userData.recommendedTopics],
                  onTopicSelected: (topic) {
                    _showTopicDetails(topic);
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Add filter options
              _showFilterOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('Zoom: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: _zoom,
                    min: 0.5,
                    max: 2.5,
                    divisions: 20,
                    label: _zoom.toStringAsFixed(1) + 'x',
                    onChanged: (value) {
                      setState(() {
                        _zoom = value;
                        _transformationController.value = Matrix4.identity()..scale(_zoom);
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.center_focus_strong),
                  onPressed: () {
                    setState(() {
                      _zoom = 1.0;
                      _transformationController.value = Matrix4.identity();
                    });
                  },
                ),
              ],
            ),
          ),
          // Legend for graph nodes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _legendItem(Colors.blue[200]!, 'Current Topics'),
                SizedBox(width: 16),
                _legendItem(Colors.amber[200]!, 'Recommended'),
                SizedBox(width: 16),
                _legendItem(Colors.green, 'Completed'),
              ],
            ),
          ),
          // Graph View
          Expanded(
            flex: 3,
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: EdgeInsets.all(double.infinity),
              minScale: 0.1,
              maxScale: 5.0,
              child: GraphView(
                graph: graph,
                algorithm: algorithm,
                paint: Paint()
                  ..color = Colors.grey
                  ..strokeWidth = 1.5
                  ..style = PaintingStyle.stroke,
                builder: _buildNodeWidget,
              ),
            ),
          ),
          // Topic Lists
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'Current Topics'),
                        Tab(text: 'Recommended'),
                      ],
                      labelColor: Theme.of(context).primaryColor,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Current Topics Tab
                          _buildTopicList(userData.learningTopics),
                          // Recommended Topics Tab
                          _buildTopicList(userData.recommendedTopics),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Add new topic logic
          _showAddTopicDialog(userData);
        },
        tooltip: 'Add New Topic',
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTopicList(List<LearningTopic> topics) {
    if (topics.isEmpty) {
      return Center(
        child: Text('No topics available'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(topic.topicName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: topic.progress / 100,
                  backgroundColor: Colors.grey.shade200,
                ),
                SizedBox(height: 4),
                Text('Progress: ${topic.progress}%'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  topic.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: topic.isCompleted ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () => _showTopicDetails(topic),
                ),
              ],
            ),
            onTap: () => _showTopicDetails(topic),
          ),
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Topics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text('Progress Status', style: Theme.of(context).textTheme.titleMedium),
            CheckboxListTile(
              title: Text('Not Started'),
              value: true, // Replace with your filter state
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('In Progress'),
              value: true, // Replace with your filter state
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('Completed'),
              value: true, // Replace with your filter state
              onChanged: (value) {},
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    Navigator.pop(context);
                  },
                  child: Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTopicDialog(UserData userData) {
    final TextEditingController _topicNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    List<String> selectedRelatedTopics = [];
    
    // Get all available topics for relationships
    List<String> availableTopics = userData.learningTopics
        .map((topic) => topic.topicName)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Topic'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _topicNameController,
                  decoration: InputDecoration(
                    labelText: 'Topic Name',
                    hintText: 'Enter the name of the topic',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a topic name';
                    }
                    if (userData.learningTopics.any((t) => t.topicName == value)) {
                      return 'This topic already exists';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                if (availableTopics.isNotEmpty) ...[
                  Text(
                    'Related Topics:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  ...availableTopics.map((topic) {
                    return CheckboxListTile(
                      title: Text(topic),
                      value: selectedRelatedTopics.contains(topic),
                      onChanged: (selected) {
                        setState(() {
                          if (selected!) {
                            selectedRelatedTopics.add(topic);
                          } else {
                            selectedRelatedTopics.remove(topic);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Create new topic
                final newTopic = LearningTopic(
                  topicName: _topicNameController.text,
                  isCompleted: false,
                  progress: 0.0,
                  relatedTopics: selectedRelatedTopics,
                );
                
                // Add to learningTopics list
                userData.learningTopics.add(newTopic);
                
                // Notify listeners to rebuild UI
                userData.notifyListeners();
                
                // Rebuild graph
                buildGraph(userData);
                
                // Close dialog
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Topic added successfully')),
                );
              }
            },
            child: Text('Add Topic'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}

// Search delegate for topics
class TopicSearchDelegate extends SearchDelegate<LearningTopic?> {
  final List<LearningTopic> allTopics;
  final Function(LearningTopic) onTopicSelected;

  TopicSearchDelegate({
    required this.allTopics,
    required this.onTopicSelected,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = query.isEmpty
        ? allTopics
        : allTopics.where((topic) =>
            topic.topicName.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final topic = results[index];
        return ListTile(
          title: Text(topic.topicName),
          subtitle: Text('Progress: ${topic.progress}%'),
          trailing: Icon(
            topic.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: topic.isCompleted ? Colors.green : Colors.grey,
          ),
          onTap: () {
            close(context, topic);
            onTopicSelected(topic);
          },
        );
      },
    );
  }
}