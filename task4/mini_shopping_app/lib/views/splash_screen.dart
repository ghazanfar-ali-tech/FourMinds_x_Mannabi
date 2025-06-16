import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mini_shopping_app/routes/app_routes.dart';
import 'package:mini_shopping_app/views/auth_screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 10), () {
      //  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
         Navigator.pushNamed(context, AppRoutes.login);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Splash Screen'),
      // ),
      body: Center(child: Lottie.asset('assets/lotties/loading_beautiful.json')),
    );
  }
}
