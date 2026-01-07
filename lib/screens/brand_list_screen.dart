import 'package:flutter/material.dart';
import '../models/brand.dart';
import '../services/api_service.dart';
import 'brand_form_screen.dart';

class BrandListScreen extends StatefulWidget {
  const BrandListScreen({super.key});

  @override
  State<BrandListScreen> createState() => _BrandListScreenState();
}

class _BrandListScreenState extends State<BrandListScreen> {
  late Future<List<Brand>> _brandList;

  @override
  void initState() {
    super.initState();
    _refreshBrands();
  }

  void _refreshBrands() {
    setState(() {
      _brandList = ApiService.getBrands();
    });
  }

  void _deleteBrand(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Brand?'),
        content: const Text('This may delete all shoes associated with this brand!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await ApiService.deleteBrand(id);
        _refreshBrands();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BRANDS', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      
      body: FutureBuilder<List<Brand>>(
        future: _brandList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.branding_watermark_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No brands added yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final brand = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: Text(
                      brand.name.isNotEmpty ? brand.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(brand.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(brand.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BrandFormScreen(brand: brand)),
                          );
                          _refreshBrands();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteBrand(brand.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BrandFormScreen()),
          );
          _refreshBrands();
        },
        backgroundColor: Colors.teal, 
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}