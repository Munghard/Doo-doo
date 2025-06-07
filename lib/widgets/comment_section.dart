import 'package:doodoo/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this for date formatting

class CommentSection extends StatefulWidget {
  final int fileId;
  final List<Map<String, dynamic>>
  comments; // Ensure this matches the expected structure
  final Function(String) onCommentSubmitted;
  final Function(String) onCommentDeleted;
  final Function(String) onCommentEdited;
  final bool loading;

  const CommentSection({
    super.key,
    required this.fileId,
    required this.comments,
    required this.onCommentSubmitted,
    required this.onCommentDeleted,
    required this.onCommentEdited,
    this.loading = false,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SupabaseService _supabaseService = SupabaseService();
  int? _hoveredIndex;

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(
      timestamp,
    ).toLocal(); // Ensure UTC is converted to local time
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime); // Format as desired
  }

  String _timeAgo(String timestamp) {
    final dateTime = DateTime.parse(
      timestamp,
    ).toLocal(); // Ensure UTC is converted to local time
    final difference = DateTime.now().difference(dateTime).abs();

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} second${difference.inSeconds == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return DateFormat(
        'yyyy-MM-dd',
      ).format(dateTime); // Fallback to date format
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: widget.loading
                  ? const Center(child: CircularProgressIndicator())
                  : widget.comments.isEmpty
                  ? const Center(child: Text('No comments yet.'))
                  : ListView.separated(
                      itemCount: widget.comments.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final comment = widget.comments[index];
                        final user = comment['user'] as Map<String, dynamic>;
                        final profilePictureUrl =
                            user['profile_picture'] as String? ?? '';
                        final userName = user['user_name'] ?? 'Anonymous';
                        final text = comment['text'] ?? '';
                        final createdAt = comment['created_at'] ?? '';
                        return ListTile(
                          leading: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/profile',
                                  arguments: user['id'],
                                );
                              },
                              child: AnimatedScale(
                                scale: _hoveredIndex == index ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 120),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: profilePictureUrl.isNotEmpty
                                      ? Image.network(
                                          profilePictureUrl,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/default-user.jpg',
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            onEnter: (_) => setState(() => _hoveredIndex = index),
                            onExit: (_) => setState(() => _hoveredIndex = null),
                          ),
                          title: Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.amber,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(text),
                              if (createdAt.isNotEmpty)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatTimestamp(createdAt),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        //edit comment
                                        if (user['id'] == Supabase.instance.client.auth.currentUser?.id)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                final TextEditingController
                                                editController =
                                                    TextEditingController(
                                                      text: comment['text'],
                                                    ); // initialize here

                                                return AlertDialog(
                                                  title: const Text(
                                                    'Edit your comment',
                                                  ),
                                                  content: TextField(
                                                    controller: editController,
                                                    maxLines: null,
                                                    decoration:
                                                        const InputDecoration(
                                                          hintText:
                                                              'Edit your comment',
                                                        ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        final newContent =
                                                            editController.text
                                                                .trim();
                                                        if (newContent
                                                            .isNotEmpty) {
                                                          await _supabaseService
                                                              .editComment(
                                                                comment['id'],
                                                                newContent,
                                                              );
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                          
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Comment edited successfully!'),
                                                          ),
                                                        );
                                                        widget.onCommentEdited(newContent); // <-- Call the event
                                                        }
                                                      },
                                                      child: const Text('Save'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        //delete comment
                                        if (user['id'] == Supabase.instance.client.auth.currentUser?.id)
                                          // Only show delete button if the comment belongs to the current user
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () async {
                                            await _supabaseService.deleteComment(
                                              comment['id'],
                                              user['id'],
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Comment deleted successfully!'),
                                              ),
                                            );
                                            widget.onCommentDeleted(comment['text']); // <-- Call the event
                                          },
                                        ),
                                        Text(
                                          _timeAgo(createdAt),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if(Supabase.instance.client.auth.currentUser != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (text) {
                        final trimmed = text.trim();
                        if (trimmed.isNotEmpty) {
                          widget.onCommentSubmitted(trimmed);
                          _commentController.clear();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = _commentController.text.trim();
                      if (text.isNotEmpty) {
                        widget.onCommentSubmitted(text);
                        _commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
