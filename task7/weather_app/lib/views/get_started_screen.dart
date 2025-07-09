import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/components/page2.dart';
import 'package:weather_app/components/page3.dart';
import 'package:weather_app/providers/on_boarding_providers.dart';
import 'package:weather_app/views/main_page.dart';
import 'package:weather_app/components/page1.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  
  late AnimationController buttonController;
  late Animation<double> buttonSize;
  
  late AnimationController skipButtonController;
  late Animation<double> skipButtonSize;

  int currentPage = 0; 
  final int totalPages = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();

    buttonController = AnimationController(
      duration: const Duration(milliseconds: 200), 
      vsync: this,
    );
    buttonSize = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
      parent: buttonController,
      curve: Curves.easeInOut,
    ));

    skipButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    skipButtonSize = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
      parent: skipButtonController,
      curve: Curves.easeInOut,
    ));
    
   
  }

  void buttonTapHandle() async {
    await buttonController.forward();
    await buttonController.reverse();
    _nextPage(); 
  }

  void skipButtonTapHandle() async {
    await skipButtonController.forward();
    await skipButtonController.reverse();
    _navigateToMainPage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    buttonController.dispose(); 
    skipButtonController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    if (provider.currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToMainPage();
    }
  }

  void _navigateToMainPage() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                currentPage = page;
              });
              Provider.of<OnboardingProvider>(context, listen: false)
                  .setCurrentPage(page);
            },
            children: [
              Page1(),
              Page2(),
              Page3(),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: ScaleTransition(
              scale: skipButtonSize,
              child: TextButton(
                onPressed: skipButtonTapHandle,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(totalPages, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == currentPage ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index == currentPage
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                ),
              );
            }),
          ),
          ScaleTransition(
            scale: buttonSize,
            child: ElevatedButton(
              onPressed: buttonTapHandle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: currentPage == 0
                    ? const Color(0xFF4A90E2)
                    : currentPage == 1
                        ? const Color(0xFF764ba2)
                        : const Color(0xFF2a5298),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                currentPage == totalPages - 1 ? 'Get Started' : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}