import 'package:flutter/material.dart';
import '../models/brand.dart';
import '../services/api_service.dart';

class BrandFormScreen extends StatefulWidget {
  final Brand? brand; // If null, we are adding. If provided, we are editing.

  const BrandFormScreen({super.key, this.brand});

  @override
  State<BrandFormScreen> createState() => _BrandFormScreenState();
}

class _BrandFormScreenState extends State<BrandFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    // Pre-fill data if editing, otherwise empty
    _nameController = TextEditingController(text: widget.brand?.name ?? '');
    _descController = TextEditingController(text: widget.brand?.description ?? '');
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newBrandData = Brand(
        id: widget.brand?.id, // Keep ID if editing
        name: _nameController.text,
        description: _descController.text,
      );

      try {
        if (widget.brand == null) {
          // ADD MODE
          await ApiService.createBrand(newBrandData);
        } else {
          // EDIT MODE
          await ApiService.updateBrand(widget.brand!.id!, newBrandData);
        }
        
        if (mounted) {
          Navigator.pop(context, true); // Return 'true' to indicate success
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.brand != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Brand' : 'Add Brand')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Brand Name', prefixIcon: Icon(Icons.abc)),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                validator: (value) => value!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(isEditing ? 'UPDATE BRAND' : 'SAVE BRAND'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}