import 'package:flutter/material.dart';
import '../models/shoe.dart';
import '../models/brand.dart';
import '../services/api_service.dart';

class AddShoeScreen extends StatefulWidget {
  const AddShoeScreen({super.key});

  @override
  State<AddShoeScreen> createState() => _AddShoeScreenState();
}

class _AddShoeScreenState extends State<AddShoeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form inputs
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  
  // To store the selected brand
  int? _selectedBrandId;
  List<Brand> _brands = [];

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  // We need to fetch brands so the user can select one from a dropdown
  void _loadBrands() async {
    try {
      final brands = await ApiService.getBrands();
      setState(() {
        _brands = brands;
      });
    } catch (e) {
      // Handle error quietly or show message
      print("Error loading brands: $e");
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedBrandId != null) {
      final newShoe = Shoe(
        modelName: _modelController.text,
        size: double.parse(_sizeController.text),
        price: double.parse(_priceController.text),
        stockQuantity: int.parse(_stockController.text),
        brandId: _selectedBrandId,
      );

      try {
        await ApiService.createShoe(newShoe);
        if (mounted) {
           Navigator.pop(context); // Go back to list screen
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding shoe: $e')),
        );
      }
    } else if (_selectedBrandId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a brand')),
      );
    }
  }

  // inside add_shoe_screen.dart build()

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('New Arrival')), // Updated Title
    body: SingleChildScrollView( // Changed to ScrollView for better keyboard handling
      padding: const EdgeInsets.all(24.0), // More breathing room
      child: Form(
        key: _formKey,
        child: Column( // Used Column for layout
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
          children: [
            const Text("Shoe Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Model Name', prefixIcon: Icon(Icons.abc)),
              validator: (value) => value!.isEmpty ? 'Enter model name' : null,
            ),
            const SizedBox(height: 16),
            
            Row( // Put Size and Price side-by-side
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeController,
                    decoration: const InputDecoration(labelText: 'Size', prefixIcon: Icon(Icons.straighten)),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter size' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price', prefixText: '₱ ', 
                    prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter price' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stock Quantity', prefixIcon: Icon(Icons.inventory)),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Brand', prefixIcon: Icon(Icons.branding_watermark)),
              value: _selectedBrandId,
              items: _brands.map((Brand brand) {
                return DropdownMenuItem<int>(
                  value: brand.id,
                  child: Text(brand.name),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedBrandId = value),
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('SAVE TO INVENTORY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ),
  );
}
}