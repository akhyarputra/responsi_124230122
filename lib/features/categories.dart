import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../service/categories_service.dart';
import 'package:hive/hive.dart';

import 'meals.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _loading = true;
  List<dynamic> _categories = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = Uri.parse(kCategoriesUrl);
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final cats = data['categories'] ?? [];
        // cache result
        final cache = Hive.box('cache_categories');
        await cache.put('data', cats);
        setState(() => _categories = List.from(cats));
      } else {
        throw Exception('Server returned ${res.statusCode}');
      }
    } catch (e) {
      // on error try load cache
      final cache = Hive.box('cache_categories');
      final cached = cache.get('data');
      if (cached != null) {
        setState(() => _categories = List.from(cached));
        setState(() => _error = 'Menampilkan data cache (offline)');
      } else {
        setState(() => _categories = []);
        setState(() => _error = 'Gagal memuat kategori. Periksa koneksi.');
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _logout(BuildContext context) async {
    final session = Hive.box('session');
    await session.delete('currentUser');
    if (context.mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final username =
        Hive.box('session').get('currentUser')?['username'] ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Categories'),
            Text('Hello, $username', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCategories,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _categories.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error ?? 'Tidak ada kategori'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchCategories,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final item = _categories[index];
                  final name = item['strCategory'] ?? '';
                  final thumb = item['strCategoryThumb'] ?? '';
                  final desc = item['strCategoryDescription'] ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Image.network(
                        thumb,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MealsScreen(category: name),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
