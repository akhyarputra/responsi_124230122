import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../service/meals_detail_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String idMeal;
  const MealDetailScreen({super.key, required this.idMeal});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _meal;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = Uri.parse(mealDetailUrl(widget.idMeal));
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final list = data['meals'];
        if (list != null && list is List && list.isNotEmpty) {
          final meal = Map<String, dynamic>.from(list.first);
          // cache
          final cache = Hive.box('cache_meal_detail');
          await cache.put(widget.idMeal, meal);
          setState(() => _meal = meal);
        }
      } else {
        throw Exception('Server ${res.statusCode}');
      }
    } catch (e) {
      final cache = Hive.box('cache_meal_detail');
      final cached = cache.get(widget.idMeal);
      if (cached != null) {
        setState(() {
          _meal = Map<String, dynamic>.from(cached);
          _error = 'Menampilkan data cache (offline)';
        });
      } else {
        setState(() => _error = 'Gagal memuat detail. Periksa koneksi.');
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  List<MapEntry<String, String>> _ingredients(Map<String, dynamic> meal) {
    final result = <MapEntry<String, String>>[];
    for (int i = 1; i <= 20; i++) {
      final ing = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ing != null && ing.toString().trim().isNotEmpty) {
        result.add(MapEntry(ing.toString(), measure?.toString() ?? ''));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _meal == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error ?? 'Detail tidak ditemukan'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchDetail,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if ((_meal!['strMealThumb'] ?? '').isNotEmpty)
                    Image.network(
                      _meal!['strMealThumb'],
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 12),
                  Text(
                    _meal!['strMeal'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category: ${_meal!['strCategory'] ?? '-'} • Area: ${_meal!['strArea'] ?? '-'}',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._ingredients(
                    _meal!,
                  ).map((e) => Text('${e.key} — ${e.value}')),
                  const SizedBox(height: 12),
                  const Text(
                    'Instructions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_meal!['strInstructions'] ?? ''),
                  const SizedBox(height: 16),
                  if ((_meal!['strYoutube'] ?? '').toString().isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final url = _meal!['strYoutube'];
                        if (url != null && url.toString().isNotEmpty) {
                          await launchUrlString(url.toString());
                        }
                      },
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Watch Cooking Video'),
                    ),
                ],
              ),
            ),
    );
  }
}
