import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:doodoo/pages/login_page.dart';
import 'package:doodoo/pages/register_page.dart';
import 'package:doodoo/widgets/image_viewer.dart';
import 'package:doodoo/pages/poop_of_the_day.dart';
import 'package:doodoo/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _images = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  int _rating = 0;
  String? postedBy;
  String? profilePictureUrl;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadAllImages();
    _loadProfile();
  }
Map<String, String> userNamesById = {};

Future<void> _loadAllImages() async {
  setState(() => _isLoading = true);
  try {
    final images = await _supabaseService.fetchFiles();
    if (images.isNotEmpty) {
      // Get unique user IDs from images
      final userIds = images.map((img) => img['posted_by'] as String?).whereType<String>().toSet();

      // Fetch usernames for all user IDs
      final profiles = await Supabase.instance.client
          .from('profiles')
          .select('id, user_name')
          .in_('id', userIds.toList());

      // Map id to user_name
      userNamesById = {
        for (final p in profiles) p['id'] as String: p['user_name'] as String? ?? 'Anon',
      };

      final avgRating = await _supabaseService.fetchAverageRating(images[0]['id']);

      setState(() {
        _images = images;
        _currentIndex = 0;
        postedBy = userNamesById[images[0]['posted_by']] ?? 'Anon';
        _rating = avgRating.round();
        _isLoading = false;
      });
    } else {
      setState(() {
        _images = [];
        _currentIndex = 0;
        postedBy = 'Anon';
        _rating = 0;
        _isLoading = false;
      });
    }
  } catch (e) {
    debugPrint('Error loading images: $e');
    setState(() => _isLoading = false);
  }
}

void _nextImage() {
  if (_images.isEmpty) return;
  setState(() {
    _currentIndex = (_currentIndex + 1) % _images.length;
    postedBy = userNamesById[_images[_currentIndex]['posted_by']] ?? 'Anon';
  });
  _updateRating();
}

  void _prevImage() {
    if (_images.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _images.length) % _images.length;
      postedBy = userNamesById[_images[_currentIndex]['posted_by']] ?? 'Anon';
    });
    _updateRating();
  }

  Future<void> _updateRating() async {
    if (_images.isNotEmpty) {
      final avgRating = await _supabaseService.fetchAverageRating(_images[_currentIndex]['id']);
      setState(() {
        _rating = avgRating.round();
      });
    }
  }

  Future<void> _addFile() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif', 'png', 'jpg'],
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      await _supabaseService.uploadFile(fileName, fileBytes);
      await _loadAllImages();
    } catch (e) {
      debugPrint('Error adding file: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addRating(int fileId, double rating) async {
    try {
      await _supabaseService.addRating(fileId, rating);
      final avgRating = await _supabaseService.fetchAverageRating(fileId);
      setState(() {
        _rating = avgRating.round();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted!')),
      );
    } catch (e) {
      debugPrint('Error adding rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    }
  }

Future<void> _loadProfile() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;

  try {
    final data = await Supabase.instance.client
        .from('profiles')
        .select('profile_picture')
        .eq('id', user.id)
        .single();

    setState(() {
      profilePictureUrl = data['profile_picture'] as String?;
      email = user.email;
    });
  } catch (e) {
    // If there's an error (e.g., no profile), just set email
    setState(() {
      email = user.email;
    });
  }
}
Future<String> _getUsername(String userId) async {
  final response = await Supabase.instance.client
      .from('profiles')
      .select('user_name')
      .eq('id', userId)
      .single();

  if (response.error != null || response.data == null) {
    return 'Anon';
  }
  
  return (response.data['user_name'] as String?) ?? 'Anon';
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontFamilyFallback: ['Noto Color Emoji'],
          ),
        ),
        actions: [
           if (profilePictureUrl != null && profilePictureUrl!.isNotEmpty)
           ClipRRect(
            borderRadius: BorderRadius.circular(20), // adjust for rounding
            child:Image.network(
              profilePictureUrl!,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
             )
            )
            else
            ClipRRect(
            borderRadius: BorderRadius.circular(20), // adjust for rounding
              child:Image.asset(
                'assets/images/default-user.jpg',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 8.0)),
          Text(Supabase.instance.client.auth.currentUser?.email ?? 'Guest'),
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'Poop of the Day',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PoopOfTheDayPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.app_registration_outlined),
            tooltip: 'Register',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage(title:'Register')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.login_outlined),
            tooltip: 'Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage(title:'Login')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () async {
               await Supabase.instance.client.auth.signOut();
               Navigator.pushReplacement(context, 
               MaterialPageRoute(builder: (context) => const LoginPage(title: 'Login')));
            },
          ),
          Padding(padding: EdgeInsets.only(right: 64.0)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ImageViewer(
              imageUrl: _images.isNotEmpty ? _images[_currentIndex]['file_url'] : null,
              imageName: _images.isNotEmpty ? _images[_currentIndex]['file_name'] : null,
              postedBy: postedBy ?? 'Anon',
              onNext: _nextImage,
              onPrev: _prevImage,
              rating: _rating.toDouble(),
              onRatingUpdate: (rating) {
                if (_images.isNotEmpty) {
                  _addRating(_images[_currentIndex]['id'], rating);
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _addFile,
        tooltip: 'Add new poop',
        child: const Text('💩', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}
