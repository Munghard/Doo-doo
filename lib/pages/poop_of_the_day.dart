import 'package:flutter/material.dart';
import 'package:doodoo/services/supabase_service.dart';

class PoopOfTheDayPage extends StatefulWidget {
  const PoopOfTheDayPage({super.key});

  @override
  _PoopOfTheDayPageState createState() => _PoopOfTheDayPageState();
}

class _PoopOfTheDayPageState extends State<PoopOfTheDayPage> {
  final SupabaseService _supabaseService = SupabaseService();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadHighestRatedImage();
  }

  Future<void> _loadHighestRatedImage() async {
    try {
      final imageUrl = await _supabaseService.fetchHighestRatedImage();
      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      debugPrint('Error loading highest-rated image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poop of the Day')),
      body: Center(
        child: _imageUrl != null
            ? Image.network(_imageUrl!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
