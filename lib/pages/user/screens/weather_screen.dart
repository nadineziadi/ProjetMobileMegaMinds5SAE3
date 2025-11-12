import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedCity = 'Tunis';
  bool _usingDefaultLocation = true;
  final TextEditingController _cityController = TextEditingController(); // Controller pour l'input
  final FocusNode _cityFocusNode = FocusNode(); // Focus node pour l'input

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _cityController.text = _selectedCity; // Initialiser avec Tunis
  }

  @override
  void dispose() {
    _cityController.dispose();
    _cityFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _usingDefaultLocation = true;
    });
    
    try {
      print('🌤️ Début du chargement de la météo...');
      
      // Essayer d'abord par localisation
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final locationWeather = await WeatherService.getWeatherByLocation(
          position.latitude, 
          position.longitude
        );
        
        if (locationWeather != null) {
          setState(() {
            _currentWeather = locationWeather;
            _selectedCity = locationWeather.city;
            _cityController.text = locationWeather.city;
            _usingDefaultLocation = false;
          });
          print('✅ Météo chargée par localisation: ${locationWeather.city}');
          return;
        }
      }
      
      // Utiliser la ville sélectionnée
      print('🔄 Utilisation de la ville: $_selectedCity');
      final cityWeather = await WeatherService.getCurrentWeather(_selectedCity);
      
      if (cityWeather != null) {
        setState(() {
          _currentWeather = cityWeather;
          _usingDefaultLocation = true;
        });
        print('✅ Météo chargée pour: $_selectedCity');
      } else {
        throw Exception('Impossible de charger la météo pour $_selectedCity');
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger la météo: $e';
      });
      print('❌ Erreur finale: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _refreshWeather() {
    _loadWeather();
  }

  void _changeCity(String city) {
    setState(() {
      _selectedCity = city;
      _cityController.text = city;
      _usingDefaultLocation = true;
    });
    _loadWeather();
  }

  // NOUVELLE MÉTHODE: Recherche par input
  void _searchCity() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      // Masquer le clavier
      _cityFocusNode.unfocus();
      
      setState(() {
        _selectedCity = city;
        _usingDefaultLocation = true;
      });
      _loadWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Météo & Entraînement',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWeather,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Indicateur de localisation
            if (_usingDefaultLocation && _currentWeather != null)
              _buildLocationIndicator(),
            
            // INPUT DE RECHERCHE - NOUVEAU
            _buildCitySearchInput(),
            const SizedBox(height: 16),
            
            // Sélecteur de ville rapide
            _buildQuickCitySelector(),
            const SizedBox(height: 20),
            
            // Carte météo principale
            if (_isLoading) _buildLoadingCard(),
            if (_errorMessage.isNotEmpty) _buildErrorCard(),
            if (_currentWeather != null && !_isLoading) _buildWeatherCard(),
            
            const SizedBox(height: 24),
            
            // Conseils d'entraînement détaillés
            if (_currentWeather != null) _buildTrainingAdviceCard(),
            
            // Prévisions supplémentaires
            if (_currentWeather != null) _buildAdditionalInfoCard(),
          ],
        ),
      ),
    );
  }

  // NOUVELLE MÉTHODE: Input de recherche de ville
  Widget _buildCitySearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              focusNode: _cityFocusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Entrez le nom d\'une ville...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _cityController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _cityController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) => _searchCity(),
              onChanged: (value) {
                setState(() {}); // Pour mettre à jour l'icône de suppression
              },
            ),
          ),
          Container(
            height: 48,
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _cityController.text.trim().isNotEmpty ? _searchCity : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFa3e635),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MÉTHODE MODIFIÉE: Sélecteur de villes rapides
  Widget _buildQuickCitySelector() {
    final popularCities = ['Tunis', 'Paris', 'Londres', 'New York', 'Tokyo', 'Dubai'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Villes populaires:',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularCities.map((city) {
            final isSelected = city == _selectedCity;
            return GestureDetector(
              onTap: () => _changeCity(city),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFFa3e635).withOpacity(0.2)
                      : const Color(0xFF2d2d2d),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFFa3e635)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  city,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFa3e635) : Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Text(
            'Localisation: $_selectedCity',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Chargement de la météo pour $_selectedCity...',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _refreshWeather,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Réessayer'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  _changeCity('Tunis');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: const Text('Retour à Tunis'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _currentWeather!.temperatureColor.withOpacity(0.3),
            _currentWeather!.temperatureColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentWeather!.temperatureColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentWeather!.city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentWeather!.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    _currentWeather!.weatherEmoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  Text(
                    '${_currentWeather!.temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(
                      color: _currentWeather!.temperatureColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(
                icon: Icons.water_drop,
                value: '${_currentWeather!.humidity.toInt()}%',
                label: 'Humidité',
              ),
              _buildWeatherDetail(
                icon: Icons.air,
                value: '${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s',
                label: 'Vent',
              ),
              _buildWeatherDetail(
                icon: Icons.thermostat,
                value: '${_currentWeather!.temperature.toStringAsFixed(1)}°C',
                label: 'Température',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingAdviceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fitness_center, color: Colors.cyan),
              SizedBox(width: 8),
              Text(
                'Conseils d\'Entraînement',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentWeather!.workoutAdvice,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations Complémentaires',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Condition actuelle', _currentWeather!.condition),
          _buildInfoRow('Humidité', '${_currentWeather!.humidity.toInt()}%'),
          _buildInfoRow('Vitesse du vent', '${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s'),
          _buildInfoRow('Localisation', _usingDefaultLocation ? 'Ville sélectionnée' : 'GPS'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}