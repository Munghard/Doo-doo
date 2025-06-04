import 'dart:typed_data';

import 'package:file_picker/src/platform_file.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  Future<List<Map<String, dynamic>>> fetchFiles() async {
    final response = await supabase
        .from('files')
        .select('id, file_url, file_name, posted_by')
        .order('created_at', ascending: false)
        .limit(10);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<double> fetchAverageRating(int fileId) async {
    final response = await supabase
        .from('ratings')
        .select('rating')
        .eq('file_id', fileId);
    if (response.isEmpty) return 0.0;
    final ratings = response.map((r) => r['rating'] as num).toList();
    return ratings.isNotEmpty
        ? ratings.reduce((a, b) => a + b) / ratings.length
        : 0.0;
  }

  Future<void> addRating(int fileId, double rating) async {
    await supabase.from('ratings').insert({
      'file_id': fileId,
      'rating': rating,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addComment(int fileId, String content) async {
    await supabase.from('comments').insert({
      'created_by': supabase.auth.currentUser?.id ?? 'anonymous',
      'content': content,
      'file_id': fileId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<String> uploadFile(String fileName, Uint8List bytes) async {
    final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await supabase.storage
        .from('ipoop-files')
        .uploadBinary(
          uniqueFileName,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/*', upsert: true),
        );
    final fileUrl = supabase.storage
        .from('ipoop-files')
        .getPublicUrl(uniqueFileName);
    await supabase.from('files').insert({
      'file_name': fileName,
      'file_url': fileUrl,
      'posted_by': supabase.auth.currentUser?.id ?? 'anonymous',
      'created_at': DateTime.now().toIso8601String(),
    });
    return fileUrl;
  }

  Future<String?> fetchHighestRatedImage({DateTime? since}) async {
    try {
      var query = Supabase.instance.client
          .from('files')
          .select('file_url, ratings(rating)');

      if (since != null) {
        // Apply the filter on the related ratings table, not files directly
        // Supabase supports filtering on related tables like:
        query = query.filter(
          'ratings.created_at',
          'gte',
          since.toIso8601String(),
        );
      }

      final List files = await query;

      String? topImageUrl;
      int highestSum = -1;

      for (final file in files) {
        final ratings = file['ratings'] as List<dynamic>? ?? [];
        final sum = ratings.fold<int>(
          0,
          (prev, r) => prev + (r['rating'] as int),
        );
        if (sum > highestSum) {
          highestSum = sum;
          topImageUrl = file['file_url'] as String?;
        }
      }
      return topImageUrl;
    } catch (e) {
      debugPrint('Error fetching highest rated image: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getComments(int fileId) async {
    try {
      final response = await supabase
          .from('comments')
          .select('content, created_by, created_at')
          .eq('file_id', fileId)
          .order(
            'created_at',
            ascending: true,
          ); // Ensure consistent ascending order

      if (response == null || response.isEmpty) {
        return [];
      }

      // Explicitly cast the response to List<Map<String, dynamic>>
      final List<Map<String, dynamic>> comments =
          List<Map<String, dynamic>>.from(response);

      // Extract unique user IDs
      final userIds = comments
          .map((c) => c['created_by'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      // Fetch profiles for these users
      final profiles = await supabase
          .from('profiles')
          .select('id, user_name, profile_picture')
          .in_('id', userIds);

      // Map profiles by user ID for quick lookup
      final profilesById = {
        for (var p in profiles) p['id'] as String: p as Map<String, dynamic>,
      };

      // Merge comment data with user profile info
      return comments.map((comment) {
        final userId = comment['created_by'] as String?;
        final profile =
            profilesById[userId] ??
            {'user_name': 'Anonymous', 'profile_picture': ''};
        return {
          'text': comment['content'] ?? '',
          'user': profile,
          'created_at': comment['created_at'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String? userId) async {
    if (userId == null) return null;

    try {
      final response = await supabase
          .from('profiles')
          .select('user_name, profile_picture')
          .eq('id', userId)
          .single();

      if (response == null) {
        return null;
      }

      return {
        'user_name': response['user_name'] ?? 'Anonymous',
        'profile_picture': response['profile_picture'] ?? '',
      };
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<bool> changeProfilePicture(String userId, PlatformFile file) async {
    if (userId.isEmpty) {
      debugPrint('Error: User ID is empty.');
      return false;
    }

    final fileName = file.name;
    final bytes = file.bytes;

    if (bytes == null) {
      debugPrint('Error: File bytes are null.');
      return false;
    }

    try {
      // Validate file type (optional, based on your requirements)
      if (!fileName.toLowerCase().endsWith('.jpg') &&
          !fileName.toLowerCase().endsWith('.jpeg') &&
          !fileName.toLowerCase().endsWith('.png') &&
          !fileName.toLowerCase().endsWith('.gif')) {
        debugPrint('Error: Unsupported file type.');
        return false;
      }

      // Upload the file to Supabase storage
      final url = await uploadFile(fileName, bytes);

      // Update the profile picture URL in the database
      await supabase
          .from('profiles')
          .update({'profile_picture': url})
          .eq('id', userId);

      debugPrint('Profile picture updated successfully.');
      return true;
    } catch (e) {
      debugPrint('Error in changeProfilePicture: $e');
      return false;
    }
  }
}
