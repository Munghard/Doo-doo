import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

class CommentSection extends StatefulWidget {
  final int fileId;
  final List<Map<String, dynamic>> comments; // Ensure this matches the expected structure
  final Function(String) onCommentSubmitted;
  final bool loading;

  const CommentSection({
    super.key,
    required this.fileId,
    required this.comments,
    required this.onCommentSubmitted,
    this.loading = false,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp).toLocal(); // Ensure UTC is converted to local time
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime); // Format as desired
  }

  String _timeAgo(String timestamp) {
    final dateTime = DateTime.parse(timestamp).toLocal(); // Ensure UTC is converted to local time
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
      return DateFormat('yyyy-MM-dd').format(dateTime); // Fallback to date format
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
                      : ListView.builder(
                          itemCount: widget.comments.length,
                          itemBuilder: (context, index) {
                            final comment = widget.comments[index];
                            final user = comment['user'] as Map<String, dynamic>;
                            final profilePictureUrl = user['profile_picture'] as String? ?? '';
                            final userName = user['user_name'] ?? 'Anonymous';
                            final text = comment['text'] ?? '';
                            final createdAt = comment['created_at'] ?? '';

                            return ListTile(
                              leading: ClipRRect(
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
                              title: Text(userName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(text),
                                  if (createdAt.isNotEmpty)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatTimestamp(createdAt),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
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
                            );
                          },
                        ),
            ),
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
