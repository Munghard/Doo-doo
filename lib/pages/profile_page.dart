import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:doodoo/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseService _supabaseService = SupabaseService();
  String? profilePictureUrl;
  String? userEmail;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadProfile();
  }

  Future<void> _checkLoginStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _isLoggedIn = user != null;
    });
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        userEmail = 'No email found';
        profilePictureUrl = null;
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('profile_picture')
          .eq('id', user.id)
          .single();

      setState(() {
        userEmail = user.email;
        profilePictureUrl = response['profile_picture'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() {
        userEmail = user.email;
        profilePictureUrl = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      await _supabaseService.changeProfilePicture(user.id, file);
      await _loadProfile(); // Reload profile to update the picture
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile picture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontFamilyFallback: ['Noto Color Emoji'],
          ),
        ),
        automaticallyImplyLeading: true, // Enable the back arrow
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Profile Page',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (profilePictureUrl != null && profilePictureUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        profilePictureUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/default-user.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    userEmail ?? 'No email found',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoggedIn) ...[
                    const Text(
                      'Change profile picture by uploading a file below:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _uploadProfilePicture,
                      child: const Text('Upload File'),
                    ),
                  ] else
                    const Text(
                      'Please log in to upload a profile picture.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
    );
  }
}