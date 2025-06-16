import 'package:flutter/material.dart';
import 'package:mini_shopping_app/routes/app_route_generator.dart';
import 'package:mini_shopping_app/routes/app_routes.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouteGenerator.generateRoute,
    );
  }
}

