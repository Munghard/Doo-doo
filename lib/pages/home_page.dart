import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:doodoo/widgets/image_viewer.dart';
import 'package:doodoo/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doodoo/widgets/rating_widget.dart';
import 'package:doodoo/widgets/comment_section.dart';
import 'package:doodoo/widgets/doodoo_navbar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String title = '💩Doo-doo';
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _images = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  double _userRating = 0.0;
  int _rating = 0;
  String? postedBy;
  String? profilePictureUrl;
  String? email;
  int _ratingCount = 0; // New property to store the number of ratings
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _loadAllImages();
    _loadProfile();
    _loadComments();
  }

  Future<void> _loadComments() async {
    if (_images.isEmpty) {
      setState(() => _comments = []);
      return;
    }

    setState(() => _isLoadingComments = true);

    try {
      final comments = await _supabaseService.getComments(
        _images[_currentIndex]['id'],
      );
      setState(() => _comments = comments);
    } catch (e) {
      debugPrint('Error loading comments: $e');
      setState(() => _comments = []);
    } finally {
      setState(() => _isLoadingComments = false);
    }
  }

  Map<String, String> userNamesById = {};

  Future<void> _loadAllImages() async {
    setState(() => _isLoading = true);
    try {
      final images = await _supabaseService.fetchFiles();
      if (images.isNotEmpty) {
        // Get unique user IDs from images
        final userIds = images
            .map((img) => img['posted_by'] as String?)
            .whereType<String>()
            .toSet();

        // Fetch usernames for all user IDs
        final profiles = await Supabase.instance.client
            .from('profiles')
            .select('id, user_name')
            .in_('id', userIds.toList());

        // Map id to user_name
        userNamesById = {
          for (final p in profiles)
            p['id'] as String: p['user_name'] as String? ?? 'Anon',
        };

        final avgRating = await _supabaseService.fetchAverageRating(
          images[0]['id'],
        );

        setState(() {
          _images = images;
          _currentIndex = 0;
          postedBy = userNamesById[images[0]['posted_by']] ?? 'Anon';
          _rating = avgRating.round();
          _isLoading = false;
        });

        // Load comments for the first image
        await _loadComments();
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
    _loadComments();
  }

  void _prevImage() {
    if (_images.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _images.length) % _images.length;
      postedBy = userNamesById[_images[_currentIndex]['posted_by']] ?? 'Anon';
    });
    _updateRating();
    _loadComments();
  }

  Future<void> _updateRating() async {
    if (_images.isNotEmpty) {
      final avgRating = await _supabaseService.fetchAverageRating(
        _images[_currentIndex]['id'],
      );
      final response = await Supabase.instance.client
          .from('ratings')
          .select('id')
          .eq('file_id', _images[_currentIndex]['id']);
      setState(() {
        _rating = avgRating.round();
        _ratingCount = response.length; // Update the rating count
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

      final bytes = result.files.single.bytes;
      if (bytes == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No file selected')));
        setState(() => _isLoading = false);
        return;
      }
      final resizedFile = await _supabaseService.resizeImageBytes(
        bytes,
        1024,
        1024,
      ); // returns File

      final fileName = result.files.first.name;

      await _supabaseService.uploadFile(fileName, resizedFile);

      await _loadAllImages();
    } catch (e) {
      debugPrint('Error adding file: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rateDoodoo(int fileId, double rating) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to rate')),
      );
      return;
    }

    try {
      final existingRating = await Supabase.instance.client
          .from('ratings')
          .select('id')
          .eq('file_id', fileId)
          .eq('rated_by', user.id)
          .maybeSingle();

      if (existingRating != null) {
        // Update existing rating
        await Supabase.instance.client
            .from('ratings')
            .update({'rating': rating})
            .eq('id', existingRating['id']);
      } else {
        // Insert new rating
        await _supabaseService.addRating(fileId, rating, user.id);
      }

      final avgRating = await _supabaseService.fetchAverageRating(fileId);
      setState(() {
        _rating = avgRating.round();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rating submitted!')));
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit rating: $e')));
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

  
  String getShortEmail(String email, {int maxLength = 6}) {
    final username = email.contains('@') ? email.split('@')[0] : email;
    if (username.length <= maxLength) return username;
    return '${username.substring(0, maxLength)}...';
  }

  Future<void> _refreshAll() async {
    await _loadAllImages();
    await _loadProfile();
    await _loadComments();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontFamilyFallback: ['Noto Color Emoji'],
          ),
        ),
        actions: [
          DoodooNavBar(
            onAddFile: _addFile,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 800,
                  ), // adjust as needed
                  child: Column(
                    children: [
                      Flexible(
                        flex:
                            5, // Allocate 50% of the height to the ImageViewer
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ImageViewer(
                            imageUrl: _images.isNotEmpty
                                ? _images[_currentIndex]['file_url']
                                : null,
                            imageName: _images.isNotEmpty
                                ? _images[_currentIndex]['file_name']
                                : null,
                            postedBy: postedBy ?? 'Anon',
                            onNext: _nextImage,
                            onPrev: _prevImage,
                            ratingCount: _ratingCount, // Pass the rating count
                          ),
                        ),
                      ),
                      Flexible(
                        flex:
                            1, // Allocate 10% of the height to the RatingWidget
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: RatingWidget(
                            userRating: _userRating,
                            rating: _rating.toDouble(),
                            ratingCount: _ratingCount, // Pass the rating count
                            onRatingUpdate: (rating) {
                              if (_images.isNotEmpty) {
                                _rateDoodoo(
                                  _images[_currentIndex]['id'],
                                  rating,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        flex:
                            4, // Allocate 40% of the height to the CommentSection
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: CommentSection(
                              fileId: _images.isNotEmpty
                                  ? _images[_currentIndex]['id']
                                  : 0,
                              comments: _images.isNotEmpty ? _comments : [],
                              loading: _isLoadingComments,
                              onCommentDeleted: (commentText) async {
                                await _refreshAll();
                              },
                              onCommentEdited: (commentText) async {
                                await _refreshAll();
                              },
                              onCommentSubmitted: (commentText) async {
                                if (_images.isEmpty) return;

                                // Add comment with user info
                                final currentUser =
                                    Supabase.instance.client.auth.currentUser;
                                final userId = currentUser?.id;

                                final userProfile = await _supabaseService
                                    .getUserProfile(userId);

                                final newComment = {
                                  'text': commentText,
                                  'user':
                                      userProfile ??
                                      {
                                        'profile_picture': '',
                                        'user_name': 'Anonymous',
                                      },
                                };

                                await _supabaseService.addComment(
                                  _images[_currentIndex]['id'],
                                  commentText,
                                );

                                setState(() {
                                  _comments.insert(0, newComment);
                                });

                                await _refreshAll();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
