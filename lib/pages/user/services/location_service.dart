import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      print('📍 Vérification des permissions de localisation...');
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Service de localisation désactivé - Utilisation de Tunis par défaut');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('📋 Permission actuelle: $permission');
      
      if (permission == LocationPermission.denied) {
        print('🔐 Demande de permission de localisation...');
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          print('❌ Permission refusée - Utilisation de Tunis par défaut');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Permission définitivement refusée - Utilisation de Tunis par défaut');
        return null;
      }

      print('📍 Obtention de la position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10), // Timeout de 10 secondes
      );
      
      print('✅ Position obtenue: ${position.latitude}, ${position.longitude}');
      return position;
      
    } catch (e) {
      print('❌ Erreur localisation - Utilisation de Tunis par défaut: $e');
      return null;
    }
  }
}