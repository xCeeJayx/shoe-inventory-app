import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/brand.dart';
import '../models/shoe.dart';

class ApiService {
  //static const String baseUrl = "http://localhost:3000/api"; 
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.1.72:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  static Future<List<Brand>> getBrands() async {
    final response = await http.get(Uri.parse('$baseUrl/brands'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Brand.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  static Future<void> createBrand(Brand brand) async {
    await http.post(
      Uri.parse('$baseUrl/brands'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(brand.toJson()),
    );
  }

  static Future<void> updateBrand(int id, Brand brand) async {
    await http.put(
      Uri.parse('$baseUrl/brands/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(brand.toJson()),
    );
  }

  static Future<void> updateShoe(int id, Shoe shoe) async {
    await http.put(
      Uri.parse('$baseUrl/shoes/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(shoe.toJson()),
    );
  }

  static Future<void> deleteBrand(int id) async {
    await http.delete(Uri.parse('$baseUrl/brands/$id'));
  }

  static Future<List<Shoe>> getShoes() async {
    final response = await http.get(Uri.parse('$baseUrl/shoes'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Shoe.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load shoes');
    }
  }

  static Future<void> createShoe(Shoe shoe) async {
    await http.post(
      Uri.parse('$baseUrl/shoes'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(shoe.toJson()),
    );
  }

  static Future<void> deleteShoe(int id) async {
    await http.delete(Uri.parse('$baseUrl/shoes/$id'));
  }
}