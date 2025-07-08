import 'package:flutter/material.dart';

class ErrorContent extends StatelessWidget {
  final String? message;

  const ErrorContent({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/error.png', // Ensure this asset exists
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          Text(
            message ?? 'City not found!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please check the spelling or try another location.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}