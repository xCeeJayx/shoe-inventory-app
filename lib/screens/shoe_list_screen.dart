import 'package:flutter/material.dart';
import '../models/shoe.dart';
import '../models/brand.dart';
import '../services/api_service.dart';
import 'add_shoe_screen.dart';
import 'edit_shoe_screen.dart';

class ShoeListScreen extends StatefulWidget {
  const ShoeListScreen({super.key});

  @override
  State<ShoeListScreen> createState() => _ShoeListScreenState();
}

class _ShoeListScreenState extends State<ShoeListScreen> {
  List<Shoe> _allShoes = [];
  List<Shoe> _filteredShoes = [];
  List<Brand> _brands = [];

  String _searchQuery = "";
  int? _selectedBrandId;
  double? _selectedSize;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final shoes = await ApiService.getShoes();
      final brands = await ApiService.getBrands();

      if (mounted) {
        setState(() {
          _allShoes = shoes;
          _brands = brands;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredShoes = _allShoes.where((shoe) {
        final matchesSearch = shoe.modelName.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesBrand = _selectedBrandId == null || shoe.brandId == _selectedBrandId;
        
        final matchesSize = _selectedSize == null || shoe.size == _selectedSize;

        return matchesSearch && matchesBrand && matchesSize;
      }).toList();
    });
  }

  List<double> _getAvailableSizes() {
    final sizes = _allShoes.map((e) => e.size).toSet().toList();
    sizes.sort();
    return sizes;
  }

  void _deleteShoe(int id) async {
    try {
      await ApiService.deleteShoe(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shoe deleted successfully')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete shoe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'INVENTORY',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddShoeScreen()),
          );
          _loadData();
        },
        label: const Text("Add Shoe"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search model name...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          labelText: "Brand",
                        ),
                        value: _selectedBrandId,
                        items: [
                          const DropdownMenuItem<int>(value: null, child: Text("All Brands")),
                          ..._brands.map((Brand brand) {
                            return DropdownMenuItem<int>(
                              value: brand.id,
                              child: Text(brand.name, overflow: TextOverflow.ellipsis),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          _selectedBrandId = value;
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          labelText: "Size",
                        ),
                        value: _selectedSize,
                        items: [
                          const DropdownMenuItem<double>(value: null, child: Text("All Sizes")),
                          ..._getAvailableSizes().map((size) {
                            return DropdownMenuItem<double>(
                              value: size,
                              child: Text(size.toString()),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          _selectedSize = value;
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredShoes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No shoes found matching filters"),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredShoes.length,
                    itemBuilder: (context, index) {
                      final shoe = _filteredShoes[index];
                      return _buildShoeCard(shoe);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoeCard(Shoe shoe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.indigo, size: 30),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₱${shoe.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              shoe.modelName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Brand: ${shoe.brandName ?? 'Unknown'}  |  Size: ${shoe.size}",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Stock: ${shoe.stockQuantity}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: shoe.stockQuantity < 5 ? Colors.red : Colors.grey[700],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.indigo),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditShoeScreen(shoe: shoe),
                          ),
                        );
                        _loadData();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteShoe(shoe.id!),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}