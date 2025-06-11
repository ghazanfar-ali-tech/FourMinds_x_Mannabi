

class UserProfile {
  String name;
  String email;
  String bio;
  List<String> hobbies;
  String? imagePath;

  UserProfile({
    required this.name,
    required this.email,
    required this.bio,
    required this.hobbies,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'bio': bio,
        'hobbies': hobbies,
        'imagePath': imagePath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'],
        email: json['email'],
        bio: json['bio'],
        hobbies: List<String>.from(json['hobbies']),
        imagePath: json['imagePath'],
      );
}
