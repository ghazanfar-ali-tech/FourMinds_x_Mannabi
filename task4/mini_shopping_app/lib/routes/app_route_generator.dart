import 'package:flutter/material.dart';
import 'package:mini_shopping_app/routes/app_routes.dart';
import 'package:mini_shopping_app/views/add_products.dart';
import 'package:mini_shopping_app/views/auth_screens/login_screen.dart';
import 'package:mini_shopping_app/views/auth_screens/signup.dart';
import 'package:mini_shopping_app/views/bottom_navigation_page/main_page_screen.dart';
import 'package:mini_shopping_app/views/buy_now_screen.dart';
import 'package:mini_shopping_app/views/profile_screen.dart';
import 'package:mini_shopping_app/views/saved_product_screen.dart';
import 'package:mini_shopping_app/views/splash_screen.dart';

class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case AppRoutes.addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      case AppRoutes.savedProduct:
        return MaterialPageRoute(builder: (_) => const SavedProductScreen());
      case AppRoutes.buyNow:
        return MaterialPageRoute(builder: (_) => const BuyNowScreen());
      case AppRoutes.myProfile:
        return MaterialPageRoute(builder: (_) => const MyProfileScreen());
      case AppRoutes.mainPage:
        return MaterialPageRoute(builder: (_) => const MainPageScreen());  
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No route found')),
          ),
        );
    }
  }
}
