import 'package:flutter/material.dart';
import 'package:doodoo/services/supabase_service.dart';
import 'package:doodoo/widgets/comment_section.dart';
import 'package:doodoo/widgets/image_viewer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PoopOfTheDayPage extends StatefulWidget {
  const PoopOfTheDayPage({super.key});

  @override
  _PoopOfTheDayPageState createState() => _PoopOfTheDayPageState();
}

class _PoopOfTheDayPageState extends State<PoopOfTheDayPage> {
  final SupabaseService _supabaseService = SupabaseService();
  String? _imageUrl;
  int? _fileId;
  String? _fileName;
  String? _postedBy;
  int _ratingCount = 0; // Correctly track the number of ratings
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = false;
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadHighestRatedImage();
  }

  Future<void> _loadHighestRatedImage() async {
    try {
      final imageUrl = await _supabaseService.fetchHighestRatedImage(since: DateTime.now().subtract(const Duration(days: 1)));
      if (imageUrl != null) {
        // Fetch the file details for the highest-rated image
        final files = await _supabaseService.fetchFiles();
        final file = files.firstWhere(
          (file) => file['file_url'] == imageUrl,
          orElse: () => {},
        );

        setState(() {
          _imageUrl = imageUrl;
          _fileId = file.isNotEmpty ? file['id'] : null;
          _fileName = file.isNotEmpty ? file['file_name'] : null;
          _postedBy = file.isNotEmpty ? file['posted_by'] : null;
          _isLoadingImage = false;
        });

        // Load ratings and comments for the highest-rated image
        if (_fileId != null) {
          await Future.wait([
            _loadRatingCount(),
            _loadComments(),
          ]);
        }
      } else {
        setState(() => _isLoadingImage = false);
      }
    } catch (e) {
      debugPrint('Error loading highest-rated image: $e');
      setState(() => _isLoadingImage = false);
    }
  }

  Future<void> _loadRatingCount() async {
    if (_fileId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('ratings')
          .select('id')
          .eq('file_id', _fileId);

      setState(() {
        _ratingCount = response.length; // Set the correct number of ratings
      });
    } catch (e) {
      debugPrint('Error loading rating count: $e');
      setState(() => _ratingCount = 0);
    }
  }

  Future<void> _loadComments() async {
    if (_fileId == null) return;

    setState(() => _isLoadingComments = true);

    try {
      final comments = await _supabaseService.getComments(_fileId!);
      setState(() => _comments = comments);
    } catch (e) {
      debugPrint('Error loading comments: $e');
      setState(() => _comments = []);
    } finally {
      setState(() => _isLoadingComments = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poop of the Day')),
      body: _isLoadingImage
    ? const Center(child: CircularProgressIndicator())
    : _imageUrl == null
        ? const Center(child: Text('No poop of the day available.'))
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600), // adjust as needed
              child: Column(
                  children: [
                    Flexible(
                      flex: 5, // Allocate 60% of the height to the ImageViewer
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ImageViewer(
                          imageUrl: _imageUrl,
                          imageName: _fileName,
                          postedBy: _postedBy,
                          ratingCount: _ratingCount, // Pass the correct rating count
                          showNavigation: false, // Disable navigation arrows
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      flex: 5, // Allocate 40% of the height to the CommentSection
                      child: Center(
                        child: FractionallySizedBox(
                          widthFactor: 1, // Set the width to 30% of the screen width
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: CommentSection(
                              fileId: _fileId ?? 0,
                              comments: _comments,
                              loading: _isLoadingComments,
                              onCommentDeleted: (commentText) async{
                              _loadComments();
                              },
                              onCommentEdited: (commentText) async{
                              _loadComments();
                              },

                              onCommentSubmitted: (commentText) async {
                                if (_fileId == null) return;

                                // Add comment with user info
                                final currentUser = Supabase.instance.client.auth.currentUser;
                                final userId = currentUser?.id;

                                // Fetch the current user profile
                                final userProfile = await _supabaseService.getUserProfile(userId);

                                final newComment = {
                                  'text': commentText,
                                  'user': userProfile ?? {
                                    'profile_picture': '',
                                    'user_name': 'Anonymous',
                                  },
                                  'created_at': DateTime.now().toIso8601String(),
                                };

                                await _supabaseService.addComment(_fileId!, commentText);

                                setState(() {
                                  _comments.insert(0, newComment); // Add the new comment to the top
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ),
    );
  }
}
