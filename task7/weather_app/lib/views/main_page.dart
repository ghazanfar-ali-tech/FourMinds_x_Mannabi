import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:weather_app/providers/data_provider.dart';
import 'package:weather_app/utils/lottie_utils.dart';
import 'package:weather_app/utils/weather_theme_utils.dart';
import 'package:weather_app/views/weather_map_screen.dart';
import 'package:weather_app/widgets/detail_weather_card.dart';
import 'package:weather_app/widgets/main_weather_card.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  AnimationController? _weatherIconController;
  AnimationController? _fadeController;
  AnimationController? _slideController;

  Animation<double>? _weatherIconAnimation;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

   late AnimationController mapButtonController;
  late Animation<double> mapButtonSize;

  final TextEditingController _searchController = TextEditingController();
  bool _isDarkMode = false;

  late String _formattedDate;
  late String _formattedTime;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _initializeAnimations();

     mapButtonController = AnimationController(
      duration: const Duration(milliseconds: 200), 
      vsync: this,
    );
    mapButtonSize = Tween<double>(begin: 1.1, end: 1.4).animate(CurvedAnimation(
      parent: mapButtonController,
      curve: Curves.easeInOut,
    ));
  }
void mapButtonTapHandle() async {
    await mapButtonController.forward();
    await mapButtonController.reverse();
    
  }
  void _updateDateTime() {
    final now = DateTime.now();
    _formattedDate = DateFormat('EEEE, MMMM d').format(now);
    _formattedTime = DateFormat('h:mm a').format(now);
  }

  void _initializeAnimations() {
    _weatherIconController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _weatherIconAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _weatherIconController!,
      curve: Curves.easeInOut,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeOutQuad),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController!.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController!.forward();
      }
    });
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for weather in $query...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
    Provider.of<DataProvider>(context, listen: false).getWeatherData(query.trim());
    _searchController.clear();
  }

  void _showMapBottomSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.90,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
      
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
    boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.2), // subtle base shadow
    blurRadius: 15,
    spreadRadius: 2,
    offset: Offset(0, -5), // upward shadow
  ),
  BoxShadow(
    color: Colors.grey.withOpacity(0.15), // layered depth
    blurRadius: 30,
    spreadRadius: 5,
    offset: Offset(0, -10), // gives it a lifted feel
  ),
],

          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
            
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: const EnhancedWeatherMap(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weatherIconController?.dispose();
    _fadeController?.dispose();
    _slideController?.dispose();
    _searchController.dispose();
     mapButtonController.dispose(); 
    super.dispose();
  }

  IconData _getWeatherIcon(String condition) {
    final cleaned = condition.toLowerCase().trim();
    if (cleaned.contains('clear') || cleaned.contains('sunny')) {
      return Icons.wb_sunny_rounded;
    } else if (cleaned.contains('partly cloudy') || cleaned.contains('cloudy')) {
      return Icons.cloud_rounded;
    } else if (cleaned.contains('overcast')) {
      return Icons.cloud_outlined;
    } else if (cleaned.contains('mist')) {
      return Icons.blur_on;
    } else if (cleaned.contains('rain')) {
      return Icons.water_drop_rounded;
    } else if (cleaned.contains('thunder')) {
      return Icons.flash_on_rounded;
    } else if (cleaned.contains('snow')) {
      return Icons.ac_unit_rounded;
    } 
    else if (cleaned.contains('light')) {
      return Icons.cloud_queue;
    }
    else {
      return Icons.wb_cloudy_rounded;
    }
  }

  void _toggleTheme() {
    HapticFeedback.selectionClick();
    setState(() {
      _isDarkMode = !_isDarkMode;
    
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final provider = Provider.of<DataProvider>(context);
    final weather = provider.weatherData;
    final isDay = weather?.current?.isDay == 1;
    final condition = weather?.current?.condition?.text ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDay),
      body: Stack(
        children: [
          // Background
          Container(decoration: getWeatherBackground(condition)),
          // Weather Lottie Animation
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: getWeatherLottie(condition),
            ),
          ),
          // Main Content
          SafeArea(
            child: _buildWeatherContent(screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(double screenWidth) {
    final content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          children: [
            SizedBox(height: screenWidth * 0.05),
            MainWeatherCard(
              weatherIconAnimation: _weatherIconAnimation,
              getWeatherIcon: _getWeatherIcon,
            ),
            SizedBox(height: screenWidth * 0.06),
            const WeatherDetailsCard(),
            SizedBox(height: screenWidth * 0.05),
           
          ],
        ),
      ),
    );

    if (_fadeAnimation != null && _slideAnimation != null) {
      return FadeTransition(
        opacity: _fadeAnimation!,
        child: SlideTransition(
          position: _slideAnimation!,
          child: content,
        ),
      );
    }

    return content;
  }

     PreferredSizeWidget _buildAppBar(bool isDay) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: _isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      title: Container(
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.3)),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
          cursorColor: Colors.white,
       decoration: InputDecoration(
  hintText: 'Search city or location',
  hintStyle: TextStyle(
    color: Colors.white.withOpacity(0.7),
  ),
  border: InputBorder.none,
  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
  prefixIcon: Icon(
    size: 22,
    Icons.search_rounded,
    color: Colors.white.withOpacity(0.8),
  ),
  prefixIconConstraints: const BoxConstraints(
    minWidth: 45,
    minHeight: 30,
  ),
),

          onSubmitted: _handleSearch,
        ),
      ),
    actions: [
  // Theme toggle button
  Container(
    margin: const EdgeInsets.only(right: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    ),
    child: IconButton(
      icon: Icon(
        isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
        color: Colors.white,
        size: 24,
      ),
      onPressed: _toggleTheme,
    ),
  ),

  // ✅ Fixed Animated Map Button
  ScaleTransition(
    scale: mapButtonSize,
    child: InkWell(
      onTap: () {
        mapButtonTapHandle(); // triggers scale animation
        _showMapBottomSheet(); // then shows map sheet
      },
      borderRadius: BorderRadius.circular(100),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Icon(
          Icons.map_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    ),
  ),
],

    );
  }
}