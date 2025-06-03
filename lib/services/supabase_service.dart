import 'dart:typed_data';

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
    final response = await supabase.from('ratings').select('rating').eq('file_id', fileId);
    if (response.isEmpty) return 0.0;
    final ratings = response.map((r) => r['rating'] as num).toList();
    return ratings.isNotEmpty ? ratings.reduce((a, b) => a + b) / ratings.length : 0.0;
  }

  Future<void> addRating(int fileId, double rating) async {
    await supabase.from('ratings').insert({
      'file_id': fileId,
      'rating': rating,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> uploadFile(String fileName, Uint8List bytes) async {
    final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await supabase.storage.from('ipoop-files').uploadBinary(
          uniqueFileName,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/*',
            upsert: true,
          ),
        );
    final fileUrl = supabase.storage.from('ipoop-files').getPublicUrl(uniqueFileName);
    await supabase.from('files').insert({
      'file_name': fileName,
      'file_url': fileUrl,
      'posted_by': supabase.auth.currentUser?.id ?? 'anonymous',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<String?> fetchHighestRatedImage() async {
    final response = await Supabase.instance.client
      .from('files')
      .select('file_url')
      .order('rating', ascending: false)
      .limit(1)
      .maybeSingle();

    if (response.error != null) {
      debugPrint('Error fetching image: ${response.error!.message}');
      return null;
    }

    final data = response.data;
    if (data != null) {
      return data['file_url'] as String?;
    }

    return null;
  }


}
