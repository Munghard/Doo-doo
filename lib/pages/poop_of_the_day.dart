import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PoopOfTheDay extends StatefulWidget {
  const PoopOfTheDay({super.key});

  @override
  _PoopOfTheDayState createState() => _PoopOfTheDayState();
}

class _PoopOfTheDayState extends State<PoopOfTheDay> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadHighestRatedImage();
  }

  Future<void> _loadHighestRatedImage() async {
  try {
    final bytes = await supabase
        .storage
        .from('ipoop-files')
        .download('1748870135619_download.jpg'); // find the highest rated imagename

    setState(() {
      _imageBytes = bytes;
    });
  } catch (e) {
    debugPrint('Error loading image: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poop of the Day')),
      body: Center(
        child: _imageBytes != null
            ? Image.memory(_imageBytes!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
