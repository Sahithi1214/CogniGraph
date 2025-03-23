import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../models/user_data.dart'; // Import UserData model

class ProfileScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    // Set the controller's text to the current user name
    _nameController.text = userData.userName;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Information:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the user name in the model
                userData.updateUserName(_nameController.text);
              },
              child: Text('Update Name'),
            ),
            SizedBox(height: 30),
            // Preferences
            Text(
              'Learning Preferences:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            userData.preferences.isEmpty
                ? Text('No preferences added yet.')
                : Column(
                    children: userData.preferences.map((preference) {
                      return ListTile(
                        title: Text(preference),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () {
                            userData.removePreference(preference);
                          },
                        ),
                      );
                    }).toList(),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add a sample preference
                userData.addPreference('Video');
              },
              child: Text('Add Learning Preference'),
            ),
          ],
        ),
      ),
    );
  }
}
