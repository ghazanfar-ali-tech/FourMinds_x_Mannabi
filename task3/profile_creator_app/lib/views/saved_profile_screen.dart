import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:profile_creator_app/models/user_profile_model.dart' show UserProfile;
import 'package:shared_preferences/shared_preferences.dart';

class SavedProfilesScreen extends StatefulWidget {
  const SavedProfilesScreen({super.key});

  @override
  State<SavedProfilesScreen> createState() => _SavedProfilesScreenState();
}

class _SavedProfilesScreenState extends State<SavedProfilesScreen> {
  List<UserProfile> profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('profiles') ?? [];
    setState(() {
      profiles = data
          .map((e) => UserProfile.fromJson(jsonDecode(e)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved Profiles")),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final p = profiles[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: p.imagePath != null
                  ? FileImage(File(p.imagePath!))
                  : NetworkImage(
                      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                    ) as ImageProvider,
            ),
            title: Text(p.name),
            subtitle: Text(p.email),
  onTap: () => showGeneralDialog(
  context: context,
  barrierDismissible: true,
  barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  barrierColor: Colors.black54,
  transitionDuration: const Duration(milliseconds: 400),
  pageBuilder: (context, animation, secondaryAnimation) {
    return Center(
      child: FadeScaleTransition(
        animation: animation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (p.imagePath != null && File(p.imagePath!).existsSync())
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: FileImage(File(p.imagePath!)),
                  )
                else
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(
                      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                    ),
                  ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.email, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text(p.email, style: TextStyle(fontSize: 16))),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text(p.bio, style: TextStyle(fontSize: 16))),
                  ],
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Hobbies:", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 6),
                ...p.hobbies.map((hobby) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text("• $hobby", style: TextStyle(fontSize: 15)),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  },
)
);
        },
      ),
    );
  }
}
