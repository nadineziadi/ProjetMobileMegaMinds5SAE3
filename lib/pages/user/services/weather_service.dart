import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class WeatherService {
  static const String _apiKey = '33e0acffcecc9cb8d071dfcfdf896f72'; // Remplacez par votre clé
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _defaultCity = 'Tunis'; // Ville par défaut
  
  static Future<WeatherData?> getCurrentWeather([String? city]) async {
    try {
      final cityToUse = city ?? _defaultCity;
      print('🌤️ Chargement météo pour: $cityToUse');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$cityToUse&appid=$_apiKey&units=metric&lang=fr')
      );
      
      if (response.statusCode == 200) {
        print('✅ Météo chargée avec succès pour $cityToUse');
        return WeatherData.fromJson(json.decode(response.body));
      } else {
        print('❌ Erreur API météo: ${response.statusCode} pour $cityToUse');
        return null;
      }
    } catch (e) {
      print('❌ Erreur connexion météo: $e');
      return null;
    }
  }


   // Méthode pour valider et formater le nom de la ville
  static String formatCityName(String city) {
    // Supprimer les espaces en trop et capitaliser
    return city.trim().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Méthode pour vérifier si une ville existe
  static Future<bool> isCityValid(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey')
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  static Future<WeatherData?> getWeatherByLocation(double lat, double lon) async {
    try {
      print('📍 Tentative de localisation: $lat, $lon');
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=fr')
      );
      
      if (response.statusCode == 200) {
        final data = WeatherData.fromJson(json.decode(response.body));
        print('✅ Météo localisée: ${data.city}');
        return data;
      } else {
        print('❌ Erreur météo par localisation: ${response.statusCode}');
        // Fallback vers Tunis
        return await getCurrentWeather();
      }
    } catch (e) {
      print('❌ Erreur localisation, fallback vers Tunis: $e');
      return await getCurrentWeather();
    }
  }
}

class WeatherData {
  final String city;
  final double temperature;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final String condition;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];
    
    return WeatherData(
      city: json['name'],
      temperature: (main['temp'] as num).toDouble(),
      description: weather['description'],
      icon: weather['icon'],
      humidity: (main['humidity'] as num).toDouble(),
      windSpeed: (wind['speed'] as num).toDouble(),
      condition: weather['main'],
    );
  }

  String get weatherEmoji {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌈';
    }
  }

  Color get temperatureColor {
    if (temperature < 0) return Colors.blue;
    if (temperature < 10) return Colors.lightBlue;
    if (temperature < 20) return Colors.green;
    if (temperature < 30) return Colors.orange;
    return Colors.red;
  }

  String get workoutAdvice {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️ Conditions parfaites ! Profitez-en pour :\n'
               '• Course à pied en extérieur\n'
               '• Vélo ou randonnée\n'
               '• Entraînement en plein air\n'
               '💡 Conseil : Hydratez-vous bien au soleil';
      
      case 'clouds':
        return '☁️ Temps idéal pour :\n'
               '• Course à pied modérée\n'
               '• Musculation en extérieur\n'
               '• Sports collectifs\n'
               '💡 Conseil : Conditions optimales pour l\'endurance';
      
      case 'rain':
        return '🌧️ Météo pluvieuse, optez pour :\n'
               '• Salle de sport\n'
               '• Natation couverte\n'
               '• Yoga ou Pilates\n'
               '💡 Conseil : Évitez les sols glissants';
      
      case 'drizzle':
        return '🌦️ Légère pluie, possibilité de :\n'
               '• Course courte avec équipement\n'
               '• Marche rapide\n'
               '• Entraînement en salle\n'
               '💡 Conseil : Vêtements imperméables recommandés';
      
      case 'thunderstorm':
        return '⛈️ Conditions dangereuses !\n'
               '• Entraînement indoor obligatoire\n'
               '• Salle de sport sécurisée\n'
               '• Exercices à domicile\n'
               '⚠️ Sécurité : Évitez absolument l\'extérieur';
      
      case 'snow':
        return '❄️ Conditions hivernales :\n'
               '• Sports d\'hiver (ski, raquettes)\n'
               '• Salle de sport chauffée\n'
               '• Natation en piscine couverte\n'
               '💡 Conseil : Équipement adapté nécessaire';
      
      case 'mist':
      case 'fog':
        return '🌫️ Visibilité réduite :\n'
               '• Salle de sport\n'
               '• Natation\n'
               '• Cardio indoor\n'
               '💡 Conseil : Privilégiez la sécurité';
      
      case 'extreme heat':
        return '🔥 Chaleur extrême :\n'
               '• Natation ou aquagym\n'
               '• Salle climatisée\n'
               '• Entraînement tôt le matin\n'
               '💡 Conseil : Hydratation maximale requise';
      
      case 'cold':
        return '🥶 Froid intense :\n'
               '• Salle de sport chauffée\n'
               '• Sports d\'hiver\n'
               '• Échauffement prolongé\n'
               '💡 Conseil : Couvrez-vous bien';
      
      default:
        return '🎯 Adaptez votre entraînement :\n'
               '• Écoutez votre corps\n'
               '• Adaptez l\'intensité\n'
               '• Choisissez l\'environnement adéquat\n'
               '💡 Conseil : La régularité prime sur l\'intensité';
    }
  }



 
}