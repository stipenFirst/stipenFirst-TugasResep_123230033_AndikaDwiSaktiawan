import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/themealdb_service.dart';
import 'detail_page.dart';
import 'favorite_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<String> categories = [
    'Burger',
    'Chicken',
    'Pasta',
    'Cake',
    'Rice',
    'Dessert',
    'Vegetarian',
    'Seafood',
    'Soup',
  ];

  String? selectedCategory;

  late Future<List<Map<String, dynamic>>> mealsFuture;

  @override
  void initState() {
    super.initState();

    // tampil random campur saat pertama buka
    mealsFuture = _loadMixedRandomMeals();
  }

  // ambil makanan random campur
  Future<List<Map<String, dynamic>>> _loadMixedRandomMeals() async {
    final random = Random();

    final List<String> sourceCategories = [
      'Chicken',
      'Seafood',
      'Dessert',
      'Vegetarian',
      'Pasta',
      'Burger',
      'Cake',
      'Soup',
    ];

    sourceCategories.shuffle(random);

    final selected = sourceCategories.take(4).toList();

    final List<Map<String, dynamic>> results = [];

    for (final item in selected) {
      List<Map<String, dynamic>> meals = [];

      // kategori asli API
      if (item == 'Chicken' ||
          item == 'Seafood' ||
          item == 'Dessert' ||
          item == 'Vegetarian' ||
          item == 'Pasta') {
        meals = await ApiService.getMealsByCategory(item);
      } else {
        // search keyword
        meals = await ApiService.searchMeals(item);
      }

      results.addAll(meals);
    }

    results.shuffle(random);

    return results.take(20).toList();
  }

  // filter dropdown
  void changeCategory(String value) {
    setState(() {
      selectedCategory = value;

      // kategori asli
      if (value == 'Chicken' ||
          value == 'Pasta' ||
          value == 'Dessert' ||
          value == 'Vegetarian' ||
          value == 'Seafood') {
        mealsFuture = ApiService.getMealsByCategory(value);
      } else {
        // keyword search
        mealsFuture = ApiService.searchMeals(value);
      }
    });
  }

  // logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("login", false);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,

        title: Text(
          currentIndex == 0
              ? "ResepKu"
              : "Favorite Saya",
        ),

        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: currentIndex == 0
          ? buildHomeContent()
          : const FavoritePage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,

        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
        ],
      ),
    );
  }

  Widget buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER ORANGE
        Container(
          width: double.infinity,

          padding: const EdgeInsets.only(
            bottom: 12,
          ),

          decoration: const BoxDecoration(
            color: Colors.orange,

            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // DROPDOWN FILTER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: DropdownButtonFormField<String>(
            value: selectedCategory,

            hint: const Text("Pilih Kategori"),

            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,

              prefixIcon: const Icon(
                Icons.restaurant_menu,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),

            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),

            onChanged: (value) {
              if (value != null) {
                changeCategory(value);
              }
            },
          ),
        ),

        const SizedBox(height: 14),

        // GRID VIEW
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: mealsFuture,

            builder: (context, snapshot) {
              // loading
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Terjadi Error\n${snapshot.error}",

                    textAlign: TextAlign.center,
                  ),
                );
              }

              // data kosong
              if (!snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "Data resep kosong",
                  ),
                );
              }

              final meals = snapshot.data!;

              return GridView.builder(
                padding: const EdgeInsets.all(16),

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,

                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,

                  childAspectRatio: 0.72,
                ),

                itemCount: meals.length,

                itemBuilder: (context, index) {
                  final meal = meals[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            id: meal['idMeal'],
                          ),
                        ),
                      );
                    },

                    child: Card(
                      elevation: 4,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          // IMAGE
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),

                              child: Image.network(
                                meal['strMealThumb'],

                                width: double.infinity,

                                fit: BoxFit.cover,

                                loadingBuilder:
                                    (context,
                                        child,
                                        progress) {
                                  if (progress == null) {
                                    return child;
                                  }

                                  return const Center(
                                    child:
                                        CircularProgressIndicator(),
                                  );
                                },

                                errorBuilder:
                                    (context,
                                        error,
                                        stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // TITLE
                          Padding(
                            padding:
                                const EdgeInsets.all(10),

                            child: Text(
                              meal['strMeal'],

                              maxLines: 2,

                              overflow:
                                  TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}