import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_shopping_app/routes/app_routes.dart';


class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String username = 'Loading...';
  String email = 'Loading...';
  String country = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

 Future<void> _loadUserData() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!mounted) return; //=>prevent setState after dispose

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          username = data?['username'] ?? 'Unknown';
          email = data?['email'] ?? 'Unknown';
          country = data?['country'] ?? 'Unknown';
        });
      } else {
        setState(() {
          username = 'No Data';
          email = 'No Data';
          country = 'No Data';
        });
      }
    } catch (e) {
      debugPrint('Failed to load user data: $e');

      if (!mounted) return; //=> important before setState
      setState(() {
        username = 'Error';
        email = 'Error';
        country = 'Error';
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'My Profile',
          style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlueAccent.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/profile.png'),
                backgroundColor: Color.fromARGB(255, 66, 185, 240),
              ),
              const SizedBox(height: 10),
              Text(
                username,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
              Text(
                'email:$email',
               
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Country: $country',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildProfileOption(context, Icons.person, 'Edit Profile'),
                    _buildProfileOption(context, Icons.history, 'Order History'),
                    _buildProfileOption(context, Icons.payment, 'Payment Methods'),
                    _buildProfileOption(context, Icons.settings, 'Settings'),
                    _buildProfileOption(
  context,
  Icons.logout,
  'Log Out',
  color: Colors.red,
  onTap: () async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  },
),

                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
  BuildContext context,
  IconData icon,
  String title, {
  Color color = Colors.black,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.withOpacity(0.2), Colors.greenAccent.withOpacity(0.2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  );
}

}
