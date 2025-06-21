import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_shopping_app/routes/app_routes.dart';

class FireBaseServices { 
  void isLogin(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user != null) {
      Timer(
        const Duration(seconds: 8),
        () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainPage,
          (route) => false, 
        ),
      );
    } else {
      Timer(
        const Duration(seconds: 8),
        () => Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
        ),
      );
    }
  }
}
