import 'package:flutter/material.dart';
import '../models/shoe.dart';
import '../models/brand.dart';
import '../services/api_service.dart';

class EditShoeScreen extends StatefulWidget {
  final Shoe shoe; // We receive the existing shoe data here

  const EditShoeScreen({super.key, required this.shoe});

  @override
  State<EditShoeScreen> createState() => _EditShoeScreenState();
}

class _EditShoeScreenState extends State<EditShoeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _modelController;
  late TextEditingController _sizeController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  
  // Brand selection
  int? _selectedBrandId;
  List<Brand> _brands = [];

  @override
  void initState() {
    super.initState();
    // 1. Initialize controllers with the EXISTING data
    _modelController = TextEditingController(text: widget.shoe.modelName);
    _sizeController = TextEditingController(text: widget.shoe.size.toString());
    _priceController = TextEditingController(text: widget.shoe.price.toString());
    _stockController = TextEditingController(text: widget.shoe.stockQuantity.toString());
    _selectedBrandId = widget.shoe.brandId;
    
    // 2. Load the brands for the dropdown
    _loadBrands();
  }

  void _loadBrands() async {
    try {
      final brands = await ApiService.getBrands();
      setState(() {
        _brands = brands;
      });
    } catch (e) {
      print("Error loading brands: $e");
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedBrandId != null) {
      // Create a Shoe object with the UPDATED values
      final updatedShoe = Shoe(
        modelName: _modelController.text,
        size: double.parse(_sizeController.text),
        price: double.parse(_priceController.text),
        stockQuantity: int.parse(_stockController.text),
        brandId: _selectedBrandId,
      );

      try {
        // Send the ID and the updated Data to the API
        await ApiService.updateShoe(widget.shoe.id!, updatedShoe);
        
        if (mounted) {
           Navigator.pop(context); // Go back to the list
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating shoe: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers when the screen is closed
    _modelController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Shoe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Modern spacing
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Update Details", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),
              
              // Model Name Input
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model Name', 
                  prefixIcon: Icon(Icons.abc)
                ),
                validator: (value) => value!.isEmpty ? 'Enter model name' : null,
              ),
              const SizedBox(height: 16),
              
              // Row for Size and Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sizeController,
                      decoration: const InputDecoration(
                        labelText: 'Size', 
                        prefixIcon: Icon(Icons.straighten)
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter size' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price', 
                        // Using Peso Symbol Here
                        prefixText: '₱ ', 
                        prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter price' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stock Input
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity', 
                  prefixIcon: Icon(Icons.inventory)
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
              ),
              const SizedBox(height: 16),
              
              // Brand Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Brand', 
                  prefixIcon: Icon(Icons.branding_watermark)
                ),
                value: _selectedBrandId,
                items: _brands.map((Brand brand) {
                  return DropdownMenuItem<int>(
                    value: brand.id,
                    child: Text(brand.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBrandId = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text(
                  'UPDATE SHOE', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}