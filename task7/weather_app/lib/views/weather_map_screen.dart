import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/data_provider.dart';
import 'package:weather_app/providers/forecastProvider.dart';
import 'package:weather_app/utils/lottie_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';


class EnhancedWeatherMap extends StatefulWidget {
  const EnhancedWeatherMap({super.key});

  @override
  State<EnhancedWeatherMap> createState() => _EnhancedWeatherMapState();
}

class _EnhancedWeatherMapState extends State<EnhancedWeatherMap>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _currentLocation;
  List<WeatherMarker> _weatherMarkers = [];
  bool _isLoading = false;
  String _selectedMapType = 'satellite';
  bool _showWeatherLayer = true;
  bool _isFabMenuOpen = false;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _fabMenuController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _fabMenuAnimation;

  //=> Debouncer for search to prevent excessive API calls
  late Debouncer _searchDebouncer;

  //=> Cache for city weather data
  final Map<String, WeatherMarker> _cityWeatherCache = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _searchDebouncer = Debouncer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMarkers();
      _updateCurrentLocation();
    });
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fabMenuController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabMenuAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabMenuController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  Future<void> _initializeMarkers() async {
    setState(() => _isLoading = true);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final majorCities = [
      {'name': 'Karachi', 'lat': 24.8607, 'lon': 67.0011},
      {'name': 'Islamabad', 'lat': 33.6844, 'lon': 73.0479},
      {'name': 'Faisalabad', 'lat': 31.4504, 'lon': 73.1350},
      {'name': 'Rawalpindi', 'lat': 33.5651, 'lon': 73.0169},
      {'name': 'Multan', 'lat': 30.1575, 'lon': 71.5249},
    ];

    _weatherMarkers = [];

    for (var city in majorCities) {
      final cityName = city['name'] as String;
      if (_cityWeatherCache.containsKey(cityName)) {
        _weatherMarkers.add(_cityWeatherCache[cityName]!);
        continue;
      }
      try {
        await dataProvider.getWeatherData(cityName);
        final weather = dataProvider.weatherData;
        if (weather != null && weather.current != null) {
          final marker = WeatherMarker(
            location: LatLng(city['lat'] as double, city['lon'] as double),
            cityName: cityName,
            temperature: '${weather.current!.tempC}°C',
            condition: weather.current!.condition?.text ?? 'Unknown',
            humidity: '${weather.current!.humidity}%',
            windSpeed: '${weather.current!.windKph} kph',
            icon: _getWeatherIcon(weather.current!.condition?.text ?? ''),
            isDay: weather.current!.isDay == 1,
          );
          _weatherMarkers.add(marker);
          _cityWeatherCache[cityName] = marker;
        }
      } catch (e) {
        print('Error loading weather for $cityName: $e');
      }
    }

    final currentLocation = _currentLocation ?? const LatLng(31.5497, 74.3436);
    await dataProvider.getWeatherData(
        '${currentLocation.latitude},${currentLocation.longitude}');

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
          });
        }
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          12.0,
        );

        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        final forecastProvider =
            Provider.of<ForecastProvider>(context, listen: false);
        await Future.wait([
          dataProvider.getWeatherData(
              '${position.latitude},${position.longitude}'),
          forecastProvider.getForecastData(
              '${position.latitude},${position.longitude}'),
        ]);
      } catch (e) {
        print('Error getting location: $e');
        _setDefaultLocation();
      }
    } else {
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    if (mounted) {
      setState(() {
        _currentLocation = const LatLng(31.5497, 74.3436);
      });
    }
    _mapController.move(const LatLng(31.5497, 74.3436), 10.0);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final forecastProvider = Provider.of<ForecastProvider>(context, listen: false);
    dataProvider.getWeatherData('Lahore');
    forecastProvider.getForecastData('Lahore');
  }

  void _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final forecastProvider = Provider.of<ForecastProvider>(context, listen: false);

    try {
      await Future.wait([
        dataProvider.getWeatherData(query.trim()),
        forecastProvider.getForecastData(query.trim()),
      ]);
      final weather = dataProvider.weatherData;
      if (weather?.location?.lat != null && weather?.location?.lon != null) {
        final newLocation = LatLng(weather!.location!.lat!, weather!.location!.lon!);
        setState(() {
          _currentLocation = newLocation;
        });
        _mapController.move(newLocation, 12.0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Showing weather for $query'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.blue.withOpacity(0.9),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Location data not available');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching weather for $query: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red.withOpacity(0.9),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    _searchController.clear();
    if (mounted) setState(() => _isLoading = false);
  }

  void _onMapTap(LatLng point) {
    HapticFeedback.lightImpact();
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final forecastProvider = Provider.of<ForecastProvider>(context, listen: false);
    dataProvider.getWeatherData('${point.latitude},${point.longitude}');
    forecastProvider.getForecastData('${point.latitude},${point.longitude}');
    _showLocationWeatherBottomSheet(point);
  }

  IconData _getWeatherIcon(String condition) {
    final cleaned = condition.toLowerCase().trim();
    if (cleaned.contains('clear') || cleaned.contains('sunny')) {
      return Icons.wb_sunny_rounded;
    } else if (cleaned.contains('partly cloudy')) {
      return Icons.cloud_circle;
    } else if (cleaned.contains('cloudy') || cleaned.contains('overcast')) {
      return Icons.cloud_rounded;
    } else if (cleaned.contains('rain') || cleaned.contains('drizzle')) {
      return Icons.water_drop_rounded;
    } else if (cleaned.contains('thunder') || cleaned.contains('storm')) {
      return Icons.flash_on_rounded;
    } else if (cleaned.contains('snow')) {
      return Icons.ac_unit_rounded;
    } else if (cleaned.contains('mist') || cleaned.contains('fog')) {
      return Icons.blur_on_rounded;
    } else {
      return Icons.wb_cloudy_rounded;
    }
  }

  String _getMapTileUrl() {
    switch (_selectedMapType) {
      case 'satellite':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case 'terrain':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Terrain_Base/MapServer/tile/{z}/{y}/{x}';
      case 'dark':
        return 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
      case 'standard':
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final weather = dataProvider.weatherData;
    final condition = weather?.current?.condition?.text ?? 'Clear';
    final temperature = weather?.current?.tempC != null
        ? '${weather!.current!.tempC}°C'
        : 'N/A';
    final humidity = weather?.current?.humidity != null
        ? '${weather!.current!.humidity}%'
        : 'N/A';
    final windSpeed = weather?.current?.windKph != null
        ? '${weather!.current!.windKph} kph'
        : 'N/A';

    _currentLocation = weather?.location?.lat != null &&
            weather?.location?.lon != null
        ? LatLng(weather!.location!.lat!, weather!.location!.lon!)
        : _currentLocation ?? const LatLng(31.5497, 74.3436);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(31.5497, 74.3436),
              initialZoom: 10.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) => _onMapTap(point),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _getMapTileUrl(),
                userAgentPackageName: 'com.example.weather_app',
                maxZoom: 18,
                subdomains: const ['a', 'b', 'c'],
                tileBuilder: (context, tileWidget, tile) {
                  return dataProvider.isDarkMode
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          ),
                          child: tileWidget,
                        )
                      : tileWidget;
                },
              ),
              if (_showWeatherLayer && _weatherMarkers.isNotEmpty)
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        width: 100,
                        height: 100,
                        child: _buildCurrentLocationMarker(
                          temperature,
                          condition,
                          humidity: humidity,
                          windSpeed: windSpeed,
                        ),
                      ),
                    ..._weatherMarkers.map(
                      (marker) => Marker(
                        point: marker.location,
                        width: 80,
                        height: 80,
                        child: _buildCityWeatherMarker(marker),
                      ),
                    ),
                  ],
                ),
              if (_currentLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentLocation!,
                      radius: 50,
                      color: Colors.blue.withOpacity(0.1),
                      borderColor: Colors.blue.withOpacity(0.5),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildTopControls(),
          ),
          Positioned(
            top: 120,
            right: 16,
            child: _buildFabMenu(),
          ),
        ],
      ),
    );
  }

Widget _buildTopControls() {
  final dataProvider = Provider.of<DataProvider>(context);
  return Column(
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dataProvider.isDarkMode
                ? [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.2),
                  ]
                : [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.3),
                  ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: dataProvider.isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.blue.shade200.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: dataProvider.isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.blue.shade100.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            color: dataProvider.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search city or location',
            hintStyle: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: dataProvider.isDarkMode
                  ? Colors.white.withOpacity(0.8)
                  : Colors.blue.shade600,
              size: 24,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: dataProvider.isDarkMode
                          ? Colors.white.withOpacity(0.8)
                          : Colors.blue.shade600,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      HapticFeedback.lightImpact();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.transparent,
          ),
          onTap: () {
            HapticFeedback.selectionClick();
          },
          onChanged: (value) {
            setState(() {}); //=> Update suffixIcon visibility
            _searchDebouncer.debounce(
              duration: const Duration(milliseconds: 500),
              onDebounce: () => _handleSearch(value),
              type: BehaviorType.trailingEdge,
            );
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _handleSearch(value);
            }
          },
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
             border: Border.all(
            color: dataProvider.isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.blue.shade200.withOpacity(0.5),
            width: 1,
          ),
         gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dataProvider.isDarkMode
                ? [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.2),
                  ]
                : [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.3),
                  ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: dataProvider.isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weather Map',
              style: TextStyle(
                color: dataProvider.isDarkMode ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            DropdownButton<String>(
              value: _selectedMapType,
              dropdownColor: dataProvider.isDarkMode
                  ? Colors.black.withOpacity(0.9)
                  : Colors.blue.shade50,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: dataProvider.isDarkMode ? Colors.white : Colors.blue.shade600,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'standard',
                  child: Text('Standard', style: TextStyle(color: Colors.black87)),
                ),
                DropdownMenuItem(
                  value: 'satellite',
                  child: Text('Satellite', style: TextStyle(color: Colors.black87)),
                ),
                DropdownMenuItem(
                  value: 'terrain',
                  child: Text('Terrain', style: TextStyle(color: Colors.black87)),
                ),
                DropdownMenuItem(
                  value: 'dark',
                  child: Text('Dark', style: TextStyle(color: Colors.black87)),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMapType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildFabMenu() {
    return AnimatedBuilder(
      animation: _fabMenuAnimation,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isFabMenuOpen)
              Column(
                children: [
                   const SizedBox(height: 60),
                  _buildFabButton(
                    icon: Icons.add,
                    heroTag: 'zoom_in',
                    onPressed: () {
                      final newZoom = (_mapController.camera.zoom + 1).clamp(3.0, 20.0);
                      _mapController.move(_mapController.camera.center, newZoom);
                    },
                    offset: Offset(0, -60 * _fabMenuAnimation.value),
                  ),
                  _buildFabButton(
                    icon: Icons.remove,
                    heroTag: 'zoom_out',
                    onPressed: () {
                      final newZoom = (_mapController.camera.zoom - 1).clamp(3.0, 18.0);
                      _mapController.move(_mapController.camera.center, newZoom);
                    },
                    offset: Offset(0, -30 * _fabMenuAnimation.value),
                  ),
                  _buildFabButton(
                    icon: Icons.my_location,
                    heroTag: 'recenter',
                    onPressed: () {
                      if (_currentLocation != null) {
                        _mapController.move(_currentLocation!, 12.0);
                      }
                    },
                    offset: Offset(0, 0 * _fabMenuAnimation.value),
                  ),
                  _buildFabButton(
                    icon: _showWeatherLayer ? Icons.cloud : Icons.cloud_off,
                    heroTag: 'weather_toggle',
                    onPressed: () {
                      setState(() {
                        _showWeatherLayer = !_showWeatherLayer;
                      });
                    },
                    offset: Offset(0, 30 * _fabMenuAnimation.value),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            _buildFabButton(
              icon: _isFabMenuOpen ? Icons.close : Icons.layers,
              heroTag: 'fab_menu',
              onPressed: () {
                setState(() {
                  _isFabMenuOpen = !_isFabMenuOpen;
                  if (_isFabMenuOpen) {
                    _fabMenuController.forward();
                  } else {
                    _fabMenuController.reverse();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFabButton({
    required IconData icon,
    required String heroTag,
    required VoidCallback onPressed,
    Offset offset = Offset.zero,
  }) {
    return Transform.translate(
      offset: offset,
      child: FloatingActionButton(
        heroTag: heroTag,
        mini: true,
        backgroundColor: Colors.white.withOpacity(0.3),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        onPressed: onPressed,
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  Widget _buildCurrentLocationMarker(
    String temperature,
    String condition, {
    String? humidity,
    String? windSpeed,
  }) {
    return GestureDetector(
      onTap: () {
        _showLocationWeatherBottomSheet(_currentLocation!);
      },
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.blue.withOpacity(0.5), Colors.blue.withOpacity(0.2)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: getWeatherLottie(condition),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  temperature,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityWeatherMarker(WeatherMarker marker) {
    return GestureDetector(
      onTap: () {
        _showLocationWeatherBottomSheet(marker.location, cityName: marker.cityName);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.black.withOpacity(0.5), Colors.black.withOpacity(0.3)],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: getWeatherLottie(marker.condition),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                marker.temperature,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationWeatherBottomSheet(LatLng point, {String? cityName}) {
  final dataProvider = Provider.of<DataProvider>(context, listen: false);
  final weather = dataProvider.weatherData;
  final cityText = weather?.location?.name ?? cityName ?? 'Unknown Location'; 
  final temperature = weather?.current?.tempC != null
      ? '${weather!.current!.tempC}°C'
      : 'N/A';
  final condition = weather?.current?.condition?.text ?? 'Unknown';
  final humidity = weather?.current?.humidity != null
      ? '${weather!.current!.humidity}%'
      : 'N/A';
  final windSpeed = weather?.current?.windKph != null
      ? '${weather!.current!.windKph} kph'
      : 'N/A';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 60,
              height: 6,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              cityText ,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.thermostat, 'Temperature', temperature),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.cloud, 'Condition', condition),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.water_drop, 'Humidity', humidity),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.air, 'Wind Speed', windSpeed),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Text(
                    "Hourly Temperature Chart",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: _buildTemperatureChart(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text('Close', style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, color: Colors.blue, size: 24),
      const SizedBox(width: 10),
      Text(
        '$label:',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}

  Widget _buildTemperatureChart(BuildContext context) {
    final forecastProvider = Provider.of<ForecastProvider>(context);
   final hours = forecastProvider.forecastData != null &&
              forecastProvider.forecastData!.forecastday.isNotEmpty
    ? forecastProvider.forecastData!.forecastday[0].hour
    : [];
    print("hours ---------- " + hours.toString());
    if (hours.isEmpty) {
      return const Center(
        child: Text(
          'Hourly forecast data not available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final data = <ChartData>[];
    for (var hour in hours) {
      data.add(
        ChartData(
          DateFormat('ha').format(DateTime.parse(hour.time)),
          hour.tempC,
        ),
      );
    }

    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        labelRotation: 45,
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        title: AxisTitle(text: 'Temperature (°C)'),
      ),
      series: <CartesianSeries>[
        LineSeries<ChartData, String>(
          dataSource: data.take(24).toList(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: Colors.blue,
          width: 3,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _fabMenuController.dispose();
    _mapController.dispose();
    _searchController.dispose();
    _searchDebouncer.cancel();
    super.dispose();
  }
}

class WeatherMarker {
  final LatLng location;
  final String cityName;
  final String temperature;
  final String condition;
  final String humidity;
  final String windSpeed;
  final IconData icon;
  final bool isDay;

  WeatherMarker({
    required this.location,
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.isDay,
  });
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}