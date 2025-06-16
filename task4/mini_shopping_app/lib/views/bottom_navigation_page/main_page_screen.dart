import 'package:flutter/material.dart';

import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mini_shopping_app/views/add_products.dart';
import 'package:mini_shopping_app/views/buy_now_screen.dart';
import 'package:mini_shopping_app/views/profile_screen.dart';
import 'package:mini_shopping_app/views/saved_product_screen.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0; //=> Track the selected index

  @override
  void dispose() {
    _pageController.dispose(); //=> Dispose of the PageController
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; //=> Update the selected index
    });
    _pageController.jumpToPage(index); //=> Jump to the selected page
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and safe area insets
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final bottomPadding = mediaQuery.padding.bottom;
    final isSmallScreen = screenWidth < 360;
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index; // Update the selected index when page changes
          });
        },
        children: <Widget>[
          SavedProductScreen(),
          AddProductScreen(),
          BuyNowScreen(),
          MyProfileScreen(),
          // Add any additional screens as necessary
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[900]!, // Start with a deep blue
              Colors.blue[800]!, // Transition to a rich blue
              Colors.blueAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0], // Adjust stops for deeper effect
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), // More rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Light shadow for elevation
              blurRadius: 20,
              offset: const Offset(0, -2), // Shadow position
            ),
          ],
        ),
        child: SafeArea(
          top: false, // Don't apply safe area to the top
          child: Padding(
            padding: EdgeInsets.only(
              top: 10.0,
              left: isSmallScreen ? 8.0 : 16.0,
              right: isSmallScreen ? 8.0 : 16.0,
              bottom: bottomPadding > 0 ? 8.0 : 16.0, // Less bottom padding if there's system navigation
            ),
            child: GNav(
              gap: isSmallScreen ? 6 : 10, // Responsive gap
              activeColor: Colors.white, // Active icon and text color
              iconSize: isSmallScreen ? 24 : 30, // Responsive icon size
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 20, 
                vertical: isSmallScreen ? 8 : 12
              ), // Responsive padding
              tabBackgroundColor: Colors.white.withOpacity(0.3), // Background color for active tab
              color: Colors.white70, // Inactive icon color
              textStyle: TextStyle(
                color: Colors.white, // Global text color for all tabs
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: "Home",
                  iconColor: _selectedIndex == 0 ? Colors.white : Colors.white70,
                ),
                GButton(
                  icon: Icons.library_add_outlined,
                  text: "Add",
                  iconColor: _selectedIndex == 1 ? Colors.white : Colors.white70,
                ),
                GButton(
                  icon: Icons.shopping_cart_outlined,
                  text: "Cart",
                  iconColor: _selectedIndex == 2 ? Colors.white : Colors.white70,
                ),
                GButton(
                  icon: Icons.person,
                  text: "Profile",
                  iconColor: _selectedIndex == 3 ? Colors.white : Colors.white70,
                ),
              ],
              selectedIndex: _selectedIndex, // Set the selected index
              onTabChange: _onItemTapped, // Call the tap handler
              rippleColor: Colors.white.withOpacity(0.5), // Ripple effect color
              backgroundColor: Colors.transparent, // Make the background transparent
              curve: Curves.easeInOut, // Animation curve
              duration: const Duration(milliseconds: 300), // Animation duration
            ),
          ),
        ),
      ),
      extendBody: true,
      // Ensure the body doesn't overlap with the bottom navigation
      resizeToAvoidBottomInset: false,
    );
  }
}