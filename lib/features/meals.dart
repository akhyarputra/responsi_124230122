import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../service/meals_service.dart';
import 'meals_detail.dart';

class MealsScreen extends StatefulWidget {
  final String category;
  const MealsScreen({super.key, required this.category});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  bool _loading = true;
  List<dynamic> _meals = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = Uri.parse(mealsByCategoryUrl(widget.category));
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final meals = data['meals'] ?? [];
        // cache
        final cache = Hive.box('cache_meals');
        final storedMap = Map<String, dynamic>.from(cache.get('map') ?? {});
        storedMap[widget.category] = meals;
        await cache.put('map', storedMap);
        setState(() => _meals = List.from(meals));
      } else {
        throw Exception('Server ${res.statusCode}');
      }
    } catch (e) {
      final cache = Hive.box('cache_meals');
      final storedMap = Map<String, dynamic>.from(cache.get('map') ?? {});
      final cached = storedMap[widget.category];
      if (cached != null) {
        setState(() {
          _meals = List.from(cached);
          _error = 'Menampilkan data cache (offline)';
        });
      } else {
        setState(() {
          _meals = [];
          _error = 'Gagal memuat daftar makanan. Periksa koneksi.';
        });
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: RefreshIndicator(
        onRefresh: _fetchMeals,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _meals.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error ?? 'Tidak ada makanan'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchMeals,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final item = _meals[index];
                  final id = item['idMeal'] ?? '';
                  final name = item['strMeal'] ?? '';
                  final thumb = item['strMealThumb'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MealDetailScreen(idMeal: id),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.network(thumb, fit: BoxFit.cover),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
