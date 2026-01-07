import 'package:flutter/material.dart';
import 'shoe_list_screen.dart';
import 'brand_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const ShoeListScreen(),
    const BrandListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.branding_watermark_outlined),
            selectedIcon: Icon(Icons.branding_watermark),
            label: 'Brands',
          ),
        ],
      ),
    );
  }
}