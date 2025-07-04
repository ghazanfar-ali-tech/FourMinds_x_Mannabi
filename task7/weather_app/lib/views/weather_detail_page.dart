import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:weather_app/providers/data_provider.dart';
import 'package:weather_app/utils/weather_theme_utils.dart';

class DetailedWeatherPage extends StatelessWidget {
  const DetailedWeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final weather = dataProvider.weatherData;
    final isLoading = dataProvider.isLoading || weather == null;
    final condition = weather?.current?.condition?.text ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isLoading ? 'Loading...' : 'Weather Analytics',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => dataProvider.getWeatherData("${weather?.location?.name ?? ''}"),
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: getWeatherBackground(condition),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildLocationHeader(weather, isLoading),
                  const SizedBox(height: 24),
                  _buildCurrentWeatherCard(weather, isLoading),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Weather Gauges'),
                  const SizedBox(height: 12),
                  _buildWeatherGaugesGrid(weather, isLoading),
                 
                  const SizedBox(height: 20),
                  _buildSectionTitle('Atmospheric Conditions'),
                  const SizedBox(height: 12),
                  _buildAtmosphericChart(weather, isLoading),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Weather Distribution'),
                  const SizedBox(height: 12),
                  _buildWeatherPieChart(weather, isLoading),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Location Details'),
                  const SizedBox(height: 12),
                  _buildLocationDetailsGrid(weather, isLoading),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Comfort Indices'),
                  const SizedBox(height: 12),
                  _buildComfortGrid(weather, isLoading),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader(dynamic weather, bool isLoading) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget(
            child: Container(
              width: 200,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ShimmerWidget(
            child: Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          weather?.location?.name ?? 'Unknown Location',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${weather?.location?.region ?? ''}, ${weather?.location?.country ?? ''}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentWeatherCard(dynamic weather, bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isLoading
          ? _buildCurrentWeatherShimmer()
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather?.current?.tempC?.toStringAsFixed(0) ?? '--'}°',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          weather?.current?.condition?.text ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          _getWeatherIcon(weather?.current?.condition?.code),
                          size: 64,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Feels like ${weather?.current?.feelslikeC?.toStringAsFixed(0) ?? '--'}°',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildWeatherGaugesGrid(dynamic weather, bool isLoading) {
    if (isLoading) {
      return SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(child: _buildShimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard()),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
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
      padding: const EdgeInsets.all(16),
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
              fontSize: 16,
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
                          fontSize: 12,
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

  Widget _buildTemperatureChart(dynamic weather, bool isLoading) {
    if (isLoading) {
      return Container(
        height: 250,
        child: _buildShimmerCard(),
      );
    }

    final hourlyData = weather?.forecast?.forecastday?[0]?.hour?.take(12)?.toList() ?? [];
    if (hourlyData.isEmpty) {
      return Container(
        height: 250,
        child: const Text(
          'No hourly data available',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final temperatureData = hourlyData.asMap().entries.map((entry) {
      final index = entry.key;
      final hour = entry.value;
      return ChartData(
        time: hour.time?.split(' ')[1]?.substring(0, 5) ?? '${index.toString().padLeft(2, '0')}:00',
        temperature: hour.tempC?.toDouble() ?? 0.0,
        humidity: hour.humidity?.toDouble() ?? 0.0,
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
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
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 10),
          interval: 2,
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(width: 0.5, color: Colors.white24),
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 10),
          name: 'Temperature',
          title: AxisTitle(
            text: 'Temperature (°C)',
            textStyle: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        axes: <ChartAxis>[
          NumericAxis(
            name: 'Humidity',
            opposedPosition: true,
            majorGridLines: const MajorGridLines(width: 0),
            labelStyle: const TextStyle(color: Colors.white70, fontSize: 10),
            title: AxisTitle(
              text: 'Humidity (%)',
              textStyle: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
        legend: Legend(
          isVisible: true,
          textStyle: const TextStyle(color: Colors.white),
          position: LegendPosition.top,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<ChartData, String>>[
          LineSeries<ChartData, String>(
            name: 'Temperature (°C)',
            dataSource: temperatureData,
            xValueMapper: (ChartData data, _) => data.time,
            yValueMapper: (ChartData data, _) => data.temperature,
            color: Colors.orange,
            width: 3,
            markerSettings: const MarkerSettings(
              isVisible: true,
              color: Colors.orange,
              borderColor: Colors.white,
              borderWidth: 2,
            ),
          ),
          LineSeries<ChartData, String>(
            name: 'Humidity (%)',
            dataSource: temperatureData,
            xValueMapper: (ChartData data, _) => data.time,
            yValueMapper: (ChartData data, _) => data.humidity,
            yAxisName: 'Humidity',
            color: Colors.lightBlue,
            width: 3,
            markerSettings: const MarkerSettings(
              isVisible: true,
              color: Colors.lightBlue,
              borderColor: Colors.white,
              borderWidth: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindChart(dynamic weather, bool isLoading) {
    if (isLoading) {
      return Container(
        height: 250,
        child: _buildShimmerCard(),
      );
    }

    final hourlyData = weather?.forecast?.forecastday?[0]?.hour?.take(8)?.toList() ?? [];
    if (hourlyData.isEmpty) {
      return Container(
        height: 250,
        child: const Text(
          'No hourly data available',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final windData = hourlyData.asMap().entries.map((entry) {
      final index = entry.key;
      final hour = entry.value;
      return WindData(
        direction: hour.windDir ?? 'N/A',
        speed: hour.windKph?.toDouble() ?? 0.0,
        angle: hour.windDegree?.toDouble() ?? (index * 45.0),
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
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
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(width: 0.5, color: Colors.white24),
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 10),
          title: AxisTitle(
            text: 'Wind Speed (km/h)',
            textStyle: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        title: ChartTitle(
          text: 'Wind Direction Analysis',
          textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<WindData, String>>[
          ColumnSeries<WindData, String>(
            dataSource: windData,
            xValueMapper: (WindData data, _) => data.direction,
            yValueMapper: (WindData data, _) => data.speed,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.cyan.withOpacity(0.3), Colors.cyan],
            ),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtmosphericChart(dynamic weather, bool isLoading) {
    if (isLoading) {
      return Container(
        height: 200,
        child: _buildShimmerCard(),
      );
    }

    final data = [
      AtmosphericData('Pressure', weather?.current?.pressureMb?.toDouble() ?? 1013.0, Colors.purple),
      AtmosphericData('UV Index', (weather?.current?.uv?.toDouble() ?? 0.0), Colors.orange),
      AtmosphericData('Visibility', weather?.current?.visKm?.toDouble() ?? 10.0, Colors.green),
      AtmosphericData('Cloud Cover', weather?.current?.cloud?.toDouble() ?? 0.0, Colors.grey),
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
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
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(width: 0.5, color: Colors.white24),
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        title: ChartTitle(
          text: 'Atmospheric Conditions',
          textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<AtmosphericData, String>>[
          BarSeries<AtmosphericData, String>(
            dataSource: data,
            xValueMapper: (AtmosphericData data, _) => data.parameter,
            yValueMapper: (AtmosphericData data, _) => data.value,
            pointColorMapper: (AtmosphericData data, _) => data.color,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherPieChart(dynamic weather, bool isLoading) {
    if (isLoading) {
      return Container(
        height: 250,
        child: _buildShimmerCard(),
      );
    }

    final cloudCover = weather?.current?.cloud?.toDouble() ?? 0.0;
    final humidity = weather?.current?.humidity?.toDouble() ?? 0.0;
    final clearPercentage = 100.0 - cloudCover - humidity / 2; // Simplified calculation
    final pieData = [
      PieChartData('Clear', clearPercentage.clamp(0, 100), Colors.yellow),
      PieChartData('Cloudy', cloudCover, Colors.grey),
      PieChartData('Humid', humidity / 2, Colors.blue),
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
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
      child: SfCircularChart(
        title: ChartTitle(
          text: 'Weather Conditions Distribution',
          textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        legend: Legend(
          isVisible: true,
          textStyle: const TextStyle(color: Colors.white, fontSize: 10),
          position: LegendPosition.bottom,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CircularSeries<PieChartData, String>>[
          DoughnutSeries<PieChartData, String>(
            dataSource: pieData,
            xValueMapper: (PieChartData data, _) => data.category,
            yValueMapper: (PieChartData data, _) => data.value,
            pointColorMapper: (PieChartData data, _) => data.color,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(color: Colors.white, fontSize: 10),
            ),
            innerRadius: '60%',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherShimmer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerWidget(
              child: Container(
                width: 120,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ShimmerWidget(
              child: Container(
                width: 100,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        ShimmerWidget(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildLocationDetailsGrid(dynamic weather, bool isLoading) {
    final details = [
      {'label': 'Latitude', 'value': '${weather?.location?.lat ?? 'N/A'}', 'icon': Icons.location_on},
      {'label': 'Longitude', 'value': '${weather?.location?.lon ?? 'N/A'}', 'icon': Icons.location_on},
      {'label': 'Timezone', 'value': weather?.location?.tzId ?? 'N/A', 'icon': Icons.access_time},
      {'label': 'Local Time', 'value': weather?.location?.localtime ?? 'N/A', 'icon': Icons.schedule},
    ];

    return _buildDetailGrid(details, isLoading);
  }

  Widget _buildComfortGrid(dynamic weather, bool isLoading) {
    final details = [
      {'label': 'Feels Like', 'value': '${weather?.current?.feelslikeC ?? 'N/A'}°C', 'icon': Icons.psychology},
      {'label': 'Heat Index', 'value': '${weather?.current?.heatindexC ?? 'N/A'}°C', 'icon': Icons.local_fire_department},
      {'label': 'Wind Chill', 'value': '${weather?.current?.windchillC ?? 'N/A'}°C', 'icon': Icons.ac_unit},
      {'label': 'Day/Night', 'value': weather?.current?.isDay == 1 ? 'Day' : 'Night', 'icon': Icons.wb_twilight},
    ];

    return _buildDetailGrid(details, isLoading);
  }

  Widget _buildDetailGrid(List<Map<String, dynamic>> details, bool isLoading) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: details.map((detail) {
        return isLoading
            ? _buildShimmerCard()
            : _buildDetailCard(
                label: detail['label']!,
                value: detail['value']!,
                icon: detail['icon']!,
              );
      }).toList(),
    );
  }

  Widget _buildDetailCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerWidget(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ShimmerWidget(
                  child: Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          ShimmerWidget(
            child: Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(dynamic code) {
    if (code == null) return Icons.help_outline;

    switch (code) {
      case 1000:
        return Icons.wb_sunny;
      case 1003:
        return Icons.wb_cloudy;
      case 1006:
        return Icons.cloud;
      case 1009:
        return Icons.cloud_done;
      case 1030:
        return Icons.foggy;
      case 1063:
      case 1180:
      case 1183:
        return Icons.grain;
      case 1066:
      case 1210:
      case 1213:
        return Icons.ac_unit;
      case 1087:
        return Icons.flash_on;
      case 1114:
      case 1117:
        return Icons.severe_cold;
      case 1135:
      case 1147:
        return Icons.foggy;
      case 1150:
      case 1153:
        return Icons.grain;
      case 1168:
      case 1171:
        return Icons.ac_unit;
      case 1186:
      case 1189:
      case 1192:
      case 1195:
        return Icons.grain;
      case 1198:
      case 1201:
        return Icons.ac_unit;
      case 1204:
      case 1207:
        return Icons.grain;
      case 1216:
      case 1219:
      case 1222:
      case 1225:
        return Icons.ac_unit;
      case 1237:
        return Icons.ac_unit;
      case 1240:
      case 1243:
      case 1246:
        return Icons.grain;
      case 1249:
      case 1252:
        return Icons.ac_unit;
      case 1255:
      case 1258:
        return Icons.ac_unit;
      case 1261:
      case 1264:
        return Icons.ac_unit;
      case 1273:
      case 1276:
        return Icons.flash_on;
      case 1279:
      case 1282:
        return Icons.flash_on;
      default:
        return Icons.wb_cloudy;
    }
  }
}

class ChartData {
  final String time;
  final double temperature;
  final double humidity;

  ChartData({required this.time, required this.temperature, required this.humidity});
}

class WindData {
  final String direction;
  final double speed;
  final double angle;

  WindData({required this.direction, required this.speed, required this.angle});
}

class AtmosphericData {
  final String parameter;
  final double value;
  final Color color;

  AtmosphericData(this.parameter, this.value, this.color);
}

class PieChartData {
  final String category;
  final double value;
  final Color color;

  PieChartData(this.category, this.value, this.color);
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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