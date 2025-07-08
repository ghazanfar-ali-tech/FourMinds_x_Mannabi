import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget getWeatherLottie(String condition) {
  condition = condition.toLowerCase();

  if (condition.contains('light rain') || 
      condition.contains('light rain shower') ||
      condition.contains('patchy rain') || condition.contains('patchy rain near by') ||
      condition.contains('patchy light drizzle') ||
      condition.contains('shower') ||
      condition.contains('rain')) {
    return Lottie.asset('assets/rain.json', fit: BoxFit.cover, repeat: true);

  } else if (condition.contains('sunny') || 
             condition.contains('clear')) {
    return Container(
      margin: const EdgeInsets.only(left:30.0,bottom: 200.0),
      child: Lottie.asset('assets/sunny.json', fit: BoxFit.contain, repeat: true),
    );

  } else if (condition.contains('partly cloudy') || 
             condition.contains('cloudy') || 
             condition.contains('overcast')) {
    return Lottie.asset('assets/cloudy.json', fit: BoxFit.cover, repeat: true);

  } else if (condition.contains('mist') || 
             condition.contains('fog')) {
    return Container(
      margin: const EdgeInsets.only(left:30.0,bottom: 200.0),
      child: Lottie.asset('assets/fog.json', fit: BoxFit.contain, repeat: true,),
    );
    
  } else if (condition.contains('thunder')) {
    return Container(
      margin: const EdgeInsets.only(left:30.0,bottom: 200.0),
      child: Lottie.asset('assets/thunder.json', fit: BoxFit.contain, repeat: true));
  }
  

  return const SizedBox.shrink();
}
