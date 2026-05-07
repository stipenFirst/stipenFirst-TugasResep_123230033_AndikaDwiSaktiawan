import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static Future<Map<String, dynamic>?> _requestJson(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final response = await http.get(uri);

      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static List<Map<String, dynamic>> _toMealList(dynamic rawMeals) {
    if (rawMeals == null || rawMeals is! List) return [];
    return rawMeals
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ambil daftar kategori
  static Future<List<String>> getCategories() async {
    final result = await _requestJson('list.php?c=list');
    final meals = result?['meals'];

    if (meals == null || meals is! List) return [];

    return meals
        .whereType<Map>()
        .map((item) => item['strCategory']?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  // ambil resep berdasarkan kategori
  static Future<List<Map<String, dynamic>>> getMealsByCategory(
    String category,
  ) async {
    final result = await _requestJson('filter.php?c=$category');
    return _toMealList(result?['meals']);
  }

  // ambil resep berdasarkan keyword / nama makanan
  static Future<List<Map<String, dynamic>>> searchMeals(
    String keyword,
  ) async {
    final result = await _requestJson('search.php?s=$keyword');
    return _toMealList(result?['meals']);
  }

  // ambil detail resep berdasarkan id
  static Future<Map<String, dynamic>?> getDetail(String id) async {
    final result = await _requestJson('lookup.php?i=$id');
    final meals = _toMealList(result?['meals']);
    if (meals.isEmpty) return null;
    return meals.first;
  }

  // ambil semua resep dari semua kategori
  static Future<List<Map<String, dynamic>>> getAllMeals() async {
    final allCategories = await getCategories();
    final List<Map<String, dynamic>> collectedMeals = [];

    for (final category in allCategories) {
      final meals = await getMealsByCategory(category);
      collectedMeals.addAll(meals);
    }
    return collectedMeals;
  }
}