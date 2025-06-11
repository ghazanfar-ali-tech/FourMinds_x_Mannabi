import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:profile_creator_app/models/user_profile_model.dart';
import 'package:profile_creator_app/views/saved_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _hobbyController = TextEditingController();

  List<String> hobbies = [];
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadLastProfileData();
  }

  Future<void> _loadLastProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _bioController.text = prefs.getString('bio') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      hobbies = prefs.getStringList('hobbies') ?? [];
      final imagePath = prefs.getString('profileImagePath');
      if (imagePath != null && File(imagePath).existsSync()) {
        _profileImage = File(imagePath);
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(picked.path);
      final savedImage = await File(picked.path).copy('${directory.path}/$fileName');

      setState(() {
        _profileImage = savedImage;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', savedImage.path);
    }
  }

  Future<void> _addHobby() async {
    final hobby = _hobbyController.text.trim();
    if (hobby.isNotEmpty) {
      setState(() {
        hobbies.add(hobby);
        _hobbyController.clear();
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Name and Email are required."),
      ));
      return;
    }

    final profile = UserProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      email: _emailController.text.trim(),
      hobbies: List<String>.from(hobbies),
      imagePath: _profileImage?.path,
    );

    final prefs = await SharedPreferences.getInstance();
    final existingProfiles = prefs.getStringList('profiles') ?? [];
    existingProfiles.add(jsonEncode(profile.toJson()));
    await prefs.setStringList('profiles', existingProfiles);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Profile Saved Successfully!"),
    ));

    setState(() {
      _nameController.clear();
      _bioController.clear();
      _emailController.clear();
      _hobbyController.clear();
      hobbies.clear();
      _profileImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Profile"),
        centerTitle: true,
        
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Stack(
  children: [
    InkWell(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 45,
        backgroundImage: _profileImage != null
            ? FileImage(_profileImage!)
            : NetworkImage(
                'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
              ) as ImageProvider,
      ),
    ),
    Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent,
        ),
        padding: const EdgeInsets.all(6),
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 20,
        ),
      ),
    ),
  ],
),

              
             
            ],
          ),
          SizedBox(height: 20),
          TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ),
          SizedBox(height: 20),

          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Email Address",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
          SizedBox(height: 20),

          TextField(
            controller: _bioController,
            maxLines: 2,
            decoration: InputDecoration(

              labelText: "Enter your Short Bio",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15)
              ),
            ),
          ),
          SizedBox(height: 20),

          Text("Add your hobbies or skills:", style: TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hobbyController,
                  decoration: InputDecoration(hintText: "e.g. Flutter, Photography"),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addHobby,
                child: Text("Add"),
              ),
            ],
          ),
          SizedBox(height: 10),

          if (hobbies.isNotEmpty) ...[
            Text("Your Skills:", style: TextStyle(fontWeight: FontWeight.w600)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: hobbies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text(hobbies[index]),
                );
              },
            ),
            SizedBox(height: 10),
          ],

          ElevatedButton.icon(
            onPressed: _submitProfile,
            icon: Icon(Icons.save),
            label: Text("Save Profile", ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
          ),
          SizedBox(height: 16),

          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SavedProfilesScreen()),
                );
              },
              icon: Icon(Icons.list_alt_outlined),
              label: Text("View Saved Profiles"),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
