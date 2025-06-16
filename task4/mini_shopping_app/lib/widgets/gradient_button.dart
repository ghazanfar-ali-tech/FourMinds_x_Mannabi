
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String title;
  final VoidCallback ontap;
  final bool loading;
  final Color? textColor;

  const GradientButton({
    required this.title,
    required this.ontap,
    this.loading = false,
    this.textColor = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
      
        onPressed: loading ? null : ontap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Make the button's background transparent
          shadowColor: Colors.black.withOpacity(0.5), // Shadow color
          elevation: 5, // Shadow elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.zero, // Remove default padding
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300, minHeight: 50), // Button size
            alignment: Alignment.center,
            child: loading
                ? const CircularProgressIndicator() // Show loading spinner if loading
                : Text(
                    title,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 19), // Text style
                  ),
          ),
        ),
      ),
    );
  }


  
}
