import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/themealdb_service.dart';
import '../models/favorite.dart';

class DetailPage extends StatefulWidget {
  final String id;
  const DetailPage({super.key, required this.id});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite(String id) {
    final box = Hive.box<Favorite>('favorites');
    return box.values.any((e) => e.id == id);
  }

  void toggleFavorite(Map meal) {
    final box = Hive.box<Favorite>('favorites');

    final existingIndex = box.values.toList().indexWhere(
      (e) => e.id == meal['idMeal'],
    );

    if (existingIndex != -1) {
      box.deleteAt(existingIndex);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Dihapus dari favorit")));
    } else {
      box.add(
        Favorite(
          id: meal['idMeal'],
          name: meal['strMeal'],
          thumbnail: meal['strMealThumb'],
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ditambahkan ke favorit")));
    }

    setState(() {});
  }

  List<String> getIngredients(Map meal) {
    List<String> ingredients = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];

      if (ingredient != null && ingredient.toString().isNotEmpty) {
        ingredients.add("$measure $ingredient");
      }
    }

    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Detail"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder(
        future: ApiService.getDetail(widget.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final meal = snapshot.data!;
          final fav = isFavorite(meal['idMeal']);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(meal['strMealThumb']),

                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal['strMeal'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          chip(
                            Icons.fastfood,
                            meal['strCategory'],
                          ), // 🍗 kategori
                          const SizedBox(width: 8),
                          chip(Icons.location_on, meal['strArea']), // 📍 negara
                        ],
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: fav ? Colors.red : Colors.orange,
                          foregroundColor: Colors.white, // 🔥 INI PENTING
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () => toggleFavorite(meal),
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                        ),
                        label: Text(
                          fav ? "Hapus dari Favorit" : "Tambah ke Favorit",
                          style: const TextStyle(
                            color: Colors.white,
                          ), // tulisan putih
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Bahan-bahan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ...getIngredients(meal).map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text("• $e"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Cara Memasak",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(meal['strInstructions'] ?? ""),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.orange),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}