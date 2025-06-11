import 'package:doodoo/models/doodoo.dart';
import 'package:doodoo/widgets/rating_widget.dart';
import 'package:flutter/material.dart';
import 'package:doodoo/services/supabase_service.dart';
import 'package:doodoo/widgets/comment_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoodooPage extends StatefulWidget {
  final int doodooId;
  const DoodooPage({super.key, required this.doodooId});

  @override
  _DoodooPageState createState() => _DoodooPageState();
}

class _DoodooPageState extends State<DoodooPage> {
  final SupabaseService _supabaseService = SupabaseService();
  DoodooEntry? _doodoo;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isLoadingComments = false;
  double userRating = 0;

  @override
  void initState() {
    super.initState();
    _loadDoodoo();
  }

  Future<void> _loadDoodoo() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final doodoos = await _supabaseService.fetchFullDoodoos();
      final doodoo = doodoos.firstWhere(
        (d) => d.id == widget.doodooId,
        orElse: () => throw Exception('Doodoo not found'),
      );
      setState(() {
        _doodoo = doodoo;
        userRating = doodoo.userRating; // Use the value from DoodooEntry
        _isLoading = false;
      });
      await _loadComments();
    } catch (e) {
      debugPrint('Error loading doodoo: $e');
      setState(() {
        _doodoo = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadComments() async {
    if (_doodoo == null) return;
    setState(() => _isLoadingComments = true);
    try {
      final comments = await _supabaseService.getComments(_doodoo!.id);
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Doodoo Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_doodoo == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Doodoo Details')),
        body: Center(child: Text('Doodoo not found.')),
      );
    }

    final doodoo = _doodoo!;
    final userProfile = doodoo.userProfile;
    final userName = userProfile['user_name']?.toString() ?? '';
    final profilePic = userProfile['profile_picture']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Doodoo Details')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header and image/info section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        profilePic.isNotEmpty
                            ? CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(profilePic),
                                backgroundColor: Colors.transparent,
                              )
                            : CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.brown[200],
                                child: Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          doodoo.createdAt.toString().split('T').first,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceDim,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        doodoo.fileName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: InteractiveViewer(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    doodoo.fileUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            doodoo.fileUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              '💩',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              doodoo.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.comment, size: 20, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              doodoo.numComments.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, size: 20, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              doodoo.numRatings.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    if (Supabase.instance.client.auth.currentUser != null) ...[
                      const SizedBox(height: 12),
                      RatingWidget(
                        userRating: userRating,
                        rating: doodoo.rating.toDouble(),
                        ratingCount: doodoo.numRatings,
                        onRatingUpdate: (rating) async {
                          await _supabaseService.addRating(
                            doodoo.id,
                            rating,
                            Supabase.instance.client.auth.currentUser?.id ?? '',
                          );
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Comments section takes the rest of the space
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CommentSection(
                      fileId: doodoo.id,
                      comments: _comments,
                      loading: _isLoadingComments,
                      onCommentDeleted: (commentText) async {
                        await _loadComments();
                      },
                      onCommentEdited: (commentText) async {
                        await _loadComments();
                      },
                      onCommentSubmitted: (commentText) async {
                        final currentUser = Supabase.instance.client.auth.currentUser;
                        final userId = currentUser?.id;
                        final userProfile = await _supabaseService.getUserProfile(userId);

                        final newComment = {
                          'text': commentText,
                          'user': userProfile ?? {
                            'profile_picture': '',
                            'user_name': 'Anonymous',
                          },
                          'created_at': DateTime.now().toIso8601String(),
                        };

                        await _supabaseService.addComment(doodoo.id, commentText);

                        setState(() {
                          _comments.insert(0, newComment);
                        });
                      },
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
