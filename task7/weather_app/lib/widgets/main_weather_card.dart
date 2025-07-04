import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:weather_app/providers/data_provider.dart';

class MainWeatherCard extends StatefulWidget {
  final Animation<double>? weatherIconAnimation;
  final IconData Function(String) getWeatherIcon;

  const MainWeatherCard({
    super.key,
    required this.weatherIconAnimation,
    required this.getWeatherIcon,
  });

  @override
  State<MainWeatherCard> createState() => _MainWeatherCardState();
}

class _MainWeatherCardState extends State<MainWeatherCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DataProvider>(context, listen: false).getWeatherData("Larkana");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, provider, _) {
        final weather = provider.weatherData;

        if (provider.isLoading || weather == null) {
          return _buildShimmerCard();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
   
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${weather.location?.name ?? "Unknown"}, ${weather.location?.country ?? "Unknown"}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
         
              Text(
                DateFormat('EEEE, MMMM d').format(DateTime.parse(weather.location?.localtime ?? DateTime.now().toString())),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                DateFormat('h:mm a').format(DateTime.parse(weather.location?.localtime ?? DateTime.now().toString())),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
         
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.current?.tempC?.toStringAsFixed(0) ?? "--"}°',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.18,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 0.9,
                          ),
                        ),
                        Text(
                          'Feels like ${weather.current?.feelslikeC?.toStringAsFixed(0) ?? "--"}°',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        widget.weatherIconAnimation != null
                            ? AnimatedBuilder(
                                animation: widget.weatherIconAnimation!,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: widget.weatherIconAnimation!.value,
                                    child: _weatherIcon(weather),
                                  );
                                },
                              )
                            : _weatherIcon(weather),
                        const SizedBox(height: 10),
                        Text(
                          weather.current?.condition?.text ?? "--",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
           
              _buildWeatherGaugesGrid(weather),
            ],
          ),
        );
      },
    );
  }

  Widget _weatherIcon(weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        widget.getWeatherIcon(weather.current?.condition?.text ?? ""),
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildWeatherGaugesGrid(dynamic weather) {
    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(
            child: _buildGaugeCard(
              title: 'Temperature',
              value: weather?.current?.tempC?.toDouble() ?? 0.0,
              minValue: -20,
              maxValue: 50,
              unit: '°C',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildGaugeCard(
              title: 'Humidity',
              value: weather?.current?.humidity?.toDouble() ?? 0.0,
              minValue: 0,
              maxValue: 100,
              unit: '%',
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeCard({
    required String title,
    required double value,
    required double minValue,
    required double maxValue,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: minValue,
                  maximum: maxValue,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: minValue,
                      endValue: maxValue,
                      color: color.withOpacity(0.3),
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: value,
                      needleColor: color,
                      knobStyle: KnobStyle(color: color),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        '${value.toStringAsFixed(1)}$unit',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          ShimmerWidget(
            child: Container(
              width: 150,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ShimmerWidget(
            child: Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(
                      child: Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShimmerWidget(
                      child: Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: ShimmerWidget(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(child: _buildShimmerGauge()),
                const SizedBox(width: 12),
                Expanded(child: _buildShimmerGauge()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGauge() {
    return ShimmerWidget(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerWidget extends StatefulWidget {
  final Widget child;

  const ShimmerWidget({super.key, required this.child});

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_animation.value * 0.4),
          child: widget.child,
        );
      },
    );
  }
}