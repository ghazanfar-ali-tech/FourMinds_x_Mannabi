import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mini_shopping_app/services/firebase_services.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


 FireBaseServices splashScreen = FireBaseServices();
  @override
  void initState() {
    super.initState();
    splashScreen.isLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Splash Screen'),
      // ),
      // backgroundColor: Color(0xFF008000),
      body: Center(child: Lottie.asset(
         width: MediaQuery.of(context).size.width * 0.9,
        'assets/lotties/loading_beautiful.json')),
    );
  }
}
