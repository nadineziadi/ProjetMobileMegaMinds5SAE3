import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'scanned_product_model.dart';

class BarcodeScannerService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const String _historyKey = 'scanned_products_history';

  // Scanner un produit via son code-barres
  static Future<ScannedProduct?> scanProduct(String barcode) async {
    try {
      final url = Uri.parse('$_baseUrl/product/$barcode.json');
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FitLifeTracker - Flutter App - Version 1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1) {
          final product = ScannedProduct.fromOpenFoodFacts(data, barcode);
          
          // Sauvegarder dans l'historique
          await _addToHistory(product);
          
          return product;
        } else {
          return null; // Produit non trouvé
        }
      } else {
        throw Exception('Erreur lors de la récupération du produit');
      }
    } catch (e) {
      print('Erreur scan: $e');
      return null;
    }
  }

  // Rechercher des produits par nom
  static Future<List<ScannedProduct>> searchProducts(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/search?search_terms=$query&page_size=20');
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FitLifeTracker - Flutter App - Version 1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List? ?? [];
        
        return products.map((productData) {
          final barcode = productData['code'] ?? '';
          return ScannedProduct.fromOpenFoodFacts(
            {'product': productData},
            barcode,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Erreur recherche: $e');
      return [];
    }
  }

  // Sauvegarder dans l'historique
  static Future<void> _addToHistory(ScannedProduct product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      
      // Supprimer le produit s'il existe déjà
      history.removeWhere((p) => p.barcode == product.barcode);
      
      // Ajouter en tête de liste
      history.insert(0, product);
      
      // Limiter à 50 produits
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      
      // Sauvegarder
      final jsonList = history.map((p) => json.encode(p.toJson())).toList();
      await prefs.setStringList(_historyKey, jsonList);
    } catch (e) {
      print('Erreur sauvegarde historique: $e');
    }
  }

  // Récupérer l'historique
  static Future<List<ScannedProduct>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_historyKey) ?? [];
      
      return jsonList.map((jsonStr) {
        final data = json.decode(jsonStr);
        return ScannedProduct.fromJson(data);
      }).toList();
    } catch (e) {
      print('Erreur lecture historique: $e');
      return [];
    }
  }

  // Alias pour compatibilité
  static Future<List<ScannedProduct>> getScanHistory() => getHistory();

  // Effacer l'historique
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Supprimer un élément de l'historique
  static Future<void> removeFromHistory(String barcode) async {
    final history = await getHistory();
    history.removeWhere((p) => p.barcode == barcode);
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }
}

