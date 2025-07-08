class ForeCastModel {
  final List<ForecastDay> forecastday;

  ForeCastModel({required this.forecastday});

  factory ForeCastModel.fromJson(Map<String, dynamic> json) {
    return ForeCastModel(
      forecastday: json['forecast'] != null &&
              json['forecast']['forecastday'] != null
          ? (json['forecast']['forecastday'] as List)
              .map((day) => ForecastDay.fromJson(day))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'forecast': {
        'forecastday': forecastday.map((day) => day.toJson()).toList(),
      },
    };
  }
}

class ForecastDay {
  final String date;
  final int dateEpoch;
  final Day day;
  final Astro astro;
  final List<Hour> hour;

  ForecastDay({
    required this.date,
    required this.dateEpoch,
    required this.day,
    required this.astro,
    required this.hour,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'] ?? '',
      dateEpoch: json['date_epoch']?.toInt() ?? 0,
      day: Day.fromJson(json['day'] ?? {}),
      astro: Astro.fromJson(json['astro'] ?? {}),
      hour: json['hour'] != null
          ? (json['hour'] as List).map((h) => Hour.fromJson(h)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'date_epoch': dateEpoch,
      'day': day.toJson(),
      'astro': astro.toJson(),
      'hour': hour.map((h) => h.toJson()).toList(),
    };
  }
}

class Day {
  final double maxtempC;
  final double maxtempF;
  final double mintempC;
  final double mintempF;
  final double avgtempC;
  final double avgtempF;
  final double maxwindMph;
  final double maxwindKph;
  final double totalprecipMm;
  final double totalprecipIn;
  final double totalsnowCm;
  final double avgvisKm;
  final double avgvisMiles;
  final int avghumidity;
  final int dailyWillItRain;
  final int dailyChanceOfRain;
  final int dailyWillItSnow;
  final int dailyChanceOfSnow;
  final Condition condition;
  final double uv;

  Day({
    required this.maxtempC,
    required this.maxtempF,
    required this.mintempC,
    required this.mintempF,
    required this.avgtempC,
    required this.avgtempF,
    required this.maxwindMph,
    required this.maxwindKph,
    required this.totalprecipMm,
    required this.totalprecipIn,
    required this.totalsnowCm,
    required this.avgvisKm,
    required this.avgvisMiles,
    required this.avghumidity,
    required this.dailyWillItRain,
    required this.dailyChanceOfRain,
    required this.dailyWillItSnow,
    required this.dailyChanceOfSnow,
    required this.condition,
    required this.uv,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      maxtempC: (json['maxtemp_c'] ?? 0.0).toDouble(),
      maxtempF: (json['maxtemp_f'] ?? 0.0).toDouble(),
      mintempC: (json['mintemp_c'] ?? 0.0).toDouble(),
      mintempF: (json['mintemp_f'] ?? 0.0).toDouble(),
      avgtempC: (json['avgtemp_c'] ?? 0.0).toDouble(),
      avgtempF: (json['avgtemp_f'] ?? 0.0).toDouble(),
      maxwindMph: (json['maxwind_mph'] ?? 0.0).toDouble(),
      maxwindKph: (json['maxwind_kph'] ?? 0.0).toDouble(),
      totalprecipMm: (json['totalprecip_mm'] ?? 0.0).toDouble(),
      totalprecipIn: (json['totalprecip_in'] ?? 0.0).toDouble(),
      totalsnowCm: (json['totalsnow_cm'] ?? 0.0).toDouble(),
      avgvisKm: (json['avgvis_km'] ?? 0.0).toDouble(),
      avgvisMiles: (json['avgvis_miles'] ?? 0.0).toDouble(),
      avghumidity: (json['avghumidity'] ?? 0).toInt(),
      dailyWillItRain: (json['daily_will_it_rain'] ?? 0).toInt(),
      dailyChanceOfRain: (json['daily_chance_of_rain'] ?? 0).toInt(),
      dailyWillItSnow: (json['daily_will_it_snow'] ?? 0).toInt(),
      dailyChanceOfSnow: (json['daily_chance_of_snow'] ?? 0).toInt(),
      condition: Condition.fromJson(json['condition'] ?? {}),
      uv: (json['uv'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxtemp_c': maxtempC,
      'maxtemp_f': maxtempF,
      'mintemp_c': mintempC,
      'mintemp_f': mintempF,
      'avgtemp_c': avgtempC,
      'avgtemp_f': avgtempF,
      'maxwind_mph': maxwindMph,
      'maxwind_kph': maxwindKph,
      'totalprecip_mm': totalprecipMm,
      'totalprecip_in': totalprecipIn,
      'totalsnow_cm': totalsnowCm,
      'avgvis_km': avgvisKm,
      'avgvis_miles': avgvisMiles,
      'avghumidity': avghumidity,
      'daily_will_it_rain': dailyWillItRain,
      'daily_chance_of_rain': dailyChanceOfRain,
      'daily_will_it_snow': dailyWillItSnow,
      'daily_chance_of_snow': dailyChanceOfSnow,
      'condition': condition.toJson(),
      'uv': uv,
    };
  }
}

class Astro {
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final String moonPhase;
  final int moonIllumination;
  final int isMoonUp;
  final int isSunUp;

  Astro({
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.moonIllumination,
    required this.isMoonUp,
    required this.isSunUp,
  });

  factory Astro.fromJson(Map<String, dynamic> json) {
    return Astro(
      sunrise: json['sunrise'] ?? '',
      sunset: json['sunset'] ?? '',
      moonrise: json['moonrise'] ?? '',
      moonset: json['moonset'] ?? '',
      moonPhase: json['moon_phase'] ?? '',
      moonIllumination: (json['moon_illumination'] ?? 0).toInt(),
      isMoonUp: (json['is_moon_up'] ?? 0).toInt(),
      isSunUp: (json['is_sun_up'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sunrise': sunrise,
      'sunset': sunset,
      'moonrise': moonrise,
      'moonset': moonset,
      'moon_phase': moonPhase,
      'moon_illumination': moonIllumination,
      'is_moon_up': isMoonUp,
      'is_sun_up': isSunUp,
    };
  }
}

class Hour {
  final int timeEpoch;
  final String time;
  final double tempC;
  final double tempF;
  final int isDay;
  final Condition condition;
  final double windMph;
  final double windKph;
  final int windDegree;
  final String windDir;
  final double pressureMb;
  final double pressureIn;
  final double precipMm;
  final double precipIn;
  final double snowCm;
  final int humidity;
  final int cloud;
  final double feelslikeC;
  final double feelslikeF;
  final double windchillC;
  final double windchillF;
  final double heatindexC;
  final double heatindexF;
  final double dewpointC;
  final double dewpointF;
  final int willItRain;
  final int chanceOfRain;
  final int willItSnow;
  final int chanceOfSnow;
  final double visKm;
  final double visMiles;
  final double gustMph;
  final double gustKph;
  final double uv;

  Hour({
    required this.timeEpoch,
    required this.time,
    required this.tempC,
    required this.tempF,
    required this.isDay,
    required this.condition,
    required this.windMph,
    required this.windKph,
    required this.windDegree,
    required this.windDir,
    required this.pressureMb,
    required this.pressureIn,
    required this.precipMm,
    required this.precipIn,
    required this.snowCm,
    required this.humidity,
    required this.cloud,
    required this.feelslikeC,
    required this.feelslikeF,
    required this.windchillC,
    required this.windchillF,
    required this.heatindexC,
    required this.heatindexF,
    required this.dewpointC,
    required this.dewpointF,
    required this.willItRain,
    required this.chanceOfRain,
    required this.willItSnow,
    required this.chanceOfSnow,
    required this.visKm,
    required this.visMiles,
    required this.gustMph,
    required this.gustKph,
    required this.uv,
  });

  factory Hour.fromJson(Map<String, dynamic> json) {
    return Hour(
      timeEpoch: (json['time_epoch'] ?? 0).toInt(),
      time: json['time'] ?? '',
      tempC: (json['temp_c'] ?? 0.0).toDouble(),
      tempF: (json['temp_f'] ?? 0.0).toDouble(),
      isDay: (json['is_day'] ?? 0).toInt(),
      condition: Condition.fromJson(json['condition'] ?? {}),
      windMph: (json['wind_mph'] ?? 0.0).toDouble(),
      windKph: (json['wind_kph'] ?? 0.0).toDouble(),
      windDegree: (json['wind_degree'] ?? 0).toInt(),
      windDir: json['wind_dir'] ?? '',
      pressureMb: (json['pressure_mb'] ?? 0.0).toDouble(),
      pressureIn: (json['pressure_in'] ?? 0.0).toDouble(),
      precipMm: (json['precip_mm'] ?? 0.0).toDouble(),
      precipIn: (json['precip_in'] ?? 0.0).toDouble(),
      snowCm: (json['snow_cm'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0).toInt(),
      cloud: (json['cloud'] ?? 0).toInt(),
      feelslikeC: (json['feelslike_c'] ?? 0.0).toDouble(),
      feelslikeF: (json['feelslike_f'] ?? 0.0).toDouble(),
      windchillC: (json['windchill_c'] ?? 0.0).toDouble(),
      windchillF: (json['windchill_f'] ?? 0.0).toDouble(),
      heatindexC: (json['heatindex_c'] ?? 0.0).toDouble(),
      heatindexF: (json['heatindex_f'] ?? 0.0).toDouble(),
      dewpointC: (json['dewpoint_c'] ?? 0.0).toDouble(),
      dewpointF: (json['dewpoint_f'] ?? 0.0).toDouble(),
      willItRain: (json['will_it_rain'] ?? 0).toInt(),
      chanceOfRain: (json['chance_of_rain'] ?? 0).toInt(),
      willItSnow: (json['will_it_snow'] ?? 0).toInt(),
      chanceOfSnow: (json['chance_of_snow'] ?? 0).toInt(),
      visKm: (json['vis_km'] ?? 0.0).toDouble(),
      visMiles: (json['vis_miles'] ?? 0.0).toDouble(),
      gustMph: (json['gust_mph'] ?? 0.0).toDouble(),
      gustKph: (json['gust_kph'] ?? 0.0).toDouble(),
      uv: (json['uv'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_epoch': timeEpoch,
      'time': time,
      'temp_c': tempC,
      'temp_f': tempF,
      'is_day': isDay,
      'condition': condition.toJson(),
      'wind_mph': windMph,
      'wind_kph': windKph,
      'wind_degree': windDegree,
      'wind_dir': windDir,
      'pressure_mb': pressureMb,
      'pressure_in': pressureIn,
      'precip_mm': precipMm,
      'precip_in': precipIn,
      'snow_cm': snowCm,
      'humidity': humidity,
      'cloud': cloud,
      'feelslike_c': feelslikeC,
      'feelslike_f': feelslikeF,
      'windchill_c': windchillC,
      'windchill_f': windchillF,
      'heatindex_c': heatindexC,
      'heatindex_f': heatindexF,
      'dewpoint_c': dewpointC,
      'dewpoint_f': dewpointF,
      'will_it_rain': willItRain,
      'chance_of_rain': chanceOfRain,
      'will_it_snow': willItSnow,
      'chance_of_snow': chanceOfSnow,
      'vis_km': visKm,
      'vis_miles': visMiles,
      'gust_mph': gustMph,
      'gust_kph': gustKph,
      'uv': uv,
    };
  }
}

class Condition {
  final String text;
  final String icon;
  final int code;

  Condition({
    required this.text,
    required this.icon,
    required this.code,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      text: json['text'] ?? '',
      icon: json['icon'] ?? '',
      code: (json['code'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'icon': icon,
      'code': code,
    };
  }
}