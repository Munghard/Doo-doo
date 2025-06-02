import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:remindo/pages/poop_of_the_day.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://urnlhjuzszdcrvouqctd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVybmxoanV6c3pkY3J2b3VxY3RkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3Nzk5NjUsImV4cCI6MjA2NDM1NTk2NX0.7s-yOYI-Q7Wxepycj7A2jGrYpLJg1J_XlE3viHqQVv0',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doo-doo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 134, 87, 0),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.robotoTextTheme().apply(
          fontFamilyFallback: ['Noto Color Emoji'],
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '💩Doo-doo'),
    );
  }
}





class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _rating = 0;
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _images = [];
  int _currentIndex = 0;
  String? _currentImageUrl;
  String? _currentImageName;
  int? _currentImageId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllImages();
  }

  Future<void> _loadAllImages() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('files')
          .select('id, file_url, file_name')
          .order('created_at', ascending: false)
          .limit(10);

      debugPrint('Response: $response');
      if (response.isEmpty) {
        setState(() {
          _images = [];
          _currentImageUrl = null;
          _currentImageName = null;
          _currentImageId = null;
          _rating = 0;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No images found')),
        );
        return;
      }

      final List<Map<String, dynamic>> images =
          List<Map<String, dynamic>>.from(response);

      // Validate file_url
      for (var img in images) {
        debugPrint('File: ${img['file_name']}, file_url: ${img['file_url']}');
        if (img['file_url'] == null || img['file_url'].isEmpty) {
          debugPrint('Invalid or empty file_url for ${img['file_name']}');
          img['file_url'] = null;
        }
      }

      setState(() {
        _images = images;
        _currentIndex = 0;
        _currentImageUrl = images[0]['file_url'];
        _currentImageName = images[0]['file_name'] ?? 'Unknown';
        _currentImageId = images[0]['id'];
        _isLoading = false;
      });

      // Fetch average rating for the current image
      if (images.isNotEmpty && _currentImageId != null) {
        final avgRating = await _getAverageRating(_currentImageId!);
        setState(() {
          _rating = avgRating.round();
        });
      }
    } catch (e) {
      debugPrint('Error loading images: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load images: $e')),
        );
      }
    }
  }

  Future<double> _getAverageRating(int fileId) async {
    try {
      final response = await supabase
          .from('ratings')
          .select('rating')
          .eq('file_id', fileId);
      if (response.isEmpty) return 0.0;
      final ratings = response.map((r) => r['rating'] as num).toList();
      return ratings.isNotEmpty
          ? ratings.reduce((a, b) => a + b) / ratings.length
          : 0.0;
    } catch (e) {
      debugPrint('Error fetching rating: $e');
      return 0.0;
    }
  }

  Future<void> _addRating(int fileId, double rating) async {
    try {
      await supabase.from('ratings').insert({
        'file_id': fileId,
        'rating': rating,
        'created_at': DateTime.now().toIso8601String(),
      });
      final avgRating = await _getAverageRating(fileId);
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

  void _nextImage() {
    if (_images.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _images.length;
      _currentImageUrl = _images[_currentIndex]['file_url'];
      _currentImageName = _images[_currentIndex]['file_name'] ?? 'Unknown';
      _currentImageId = _images[_currentIndex]['id'];
    });
    _getAverageRating(_currentImageId!).then((avgRating) {
      setState(() {
        _rating = avgRating.round();
      });
    });
  }

  void _prevImage() {
    if (_images.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _images.length) % _images.length;
      _currentImageUrl = _images[_currentIndex]['file_url'];
      _currentImageName = _images[_currentIndex]['file_name'] ?? 'Unknown';
      _currentImageId = _images[_currentIndex]['id'];
    });
    _getAverageRating(_currentImageId!).then((avgRating) {
      setState(() {
        _rating = avgRating.round();
      });
    });
  }

  Future<void> _addFile() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif', 'png', 'jpg'],
      );
      if (result == null || result.files.isEmpty) {
        debugPrint('No file selected');
        setState(() => _isLoading = false);
        return;
      }
      Uint8List fileBytes = result.files.single.bytes!;
      String fileName = result.files.single.name;
      debugPrint('Uploading file: $fileName, size: ${fileBytes.length} bytes');

      // Validate image bytes
      try {
        await precacheImage(MemoryImage(fileBytes), context);
        debugPrint('Image bytes are valid for $fileName');
      } catch (e) {
        debugPrint('Invalid image bytes for $fileName: $e');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid image file')),
        );
        return;
      }

      // Upload to Supabase Storage
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await supabase.storage.from('ipoop-files').uploadBinary(
            uniqueFileName,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/*',
              upsert: true,
            ),
          );
      final fileUrl = supabase.storage.from('ipoop-files').getPublicUrl(uniqueFileName);

      debugPrint('File uploaded, public URL: $fileUrl');

      await supabase.from('files').insert({
        'file_name': fileName,
        'file_url': fileUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      await _loadAllImages();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('File Added'),
            content: const Text('Your poop image has been added successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to upload file: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            tooltip: 'Poop of the Day',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PoopOfTheDay()),
              );
            },
          ),
        ],
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontFamilyFallback: ['Noto Color Emoji'],

          ),
        ),
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Rate this poop:',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentImageName ?? 'No image selected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color.fromARGB(255, 112, 112, 112),),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _images.isEmpty ? null : _prevImage,
                          
                          child: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: 600,
                            maxHeight: 600,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.brown, width: 4),
                            
                          ),
                          child: _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                              ? Image.network(
                                  _currentImageUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Image loading error: $error');
                                    return const Center(child: Text('Failed to load image'));
                                  },
                                )
                              : const Center(child: Text('No images available')),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _images.isEmpty ? null : _nextImage,
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Average rating: $_rating',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    RatingBar.builder(
                      initialRating: _rating.toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Text(
                        '💩',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Roboto',
                          fontFamilyFallback: ['Noto Color Emoji'],
                        ),
                      ),
                      onRatingUpdate: (rating) {
                        if (_currentImageId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No image selected to rate')),
                          );
                          return;
                        }
                        setState(() {
                          _rating = rating.round();
                        });
                        _addRating(_currentImageId!, rating);
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _images.isEmpty ? null : _nextImage,
                      child: const Text('Next poop!'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _addFile,
        tooltip: 'Add new poop',
        // child: const Icon(Icons.add),
        child: const Icon(Icons.add),
      ),
    );
  }
}