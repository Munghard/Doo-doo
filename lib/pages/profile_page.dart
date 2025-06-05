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
  String? userName;
  int totalDoodoos = 0;
  List<dynamic> doodooList = [];  
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadProfile();
    _loadUserDoodoos();
  }

  Future<void> _checkLoginStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _isLoggedIn = user != null;
    });
  }

  Future<void> _loadUserDoodoos() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  try {
    final response = await Supabase.instance.client
        .from('files')
        .select('id, file_name, created_at, file_url')
        .eq('posted_by', userId)
        .order('created_at', ascending: false); // optional: newest first

    setState(() {
      doodooList = response;
    });
  } catch (e) {
    debugPrint('Error loading doodoo list: $e');
  }
}

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        userEmail = 'No email found';
        profilePictureUrl = null;
        totalDoodoos = 0;
        userName = 'No username found';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('profile_picture, user_name')
          .eq('id', user.id)
          .single();

      final userId = Supabase.instance.client.auth.currentUser?.id;
      final count = await _supabaseService.getTotalDoodoosByUser(userId);

      setState(() {
        userEmail = user.email;
        profilePictureUrl = response['profile_picture'] as String?;
        userName = response['user_name'] as String? ?? 'No username found';
        totalDoodoos = count;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() {
        userEmail = user.email;
        profilePictureUrl = null;
        totalDoodoos = 0;
        userName = 'No username found';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
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
        child:Padding(padding: const EdgeInsets.all(16.0),
          child:  // Use ConstrainedBox to limit the width of the profile content
         ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // adjust width as needed
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  const Text(
                    'Profile Page',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (profilePictureUrl != null &&
                      profilePictureUrl!.isNotEmpty)
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
                  Text(
                    userName ?? 'No username found',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Total doodoos: $totalDoodoos',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoggedIn) ...[
                    const Text(
                      'Change profile picture by uploading a file below:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _uploadProfilePicture,
                      child: const Text('Upload File'),
                    ),
                  ] else
                    const Text(
                      'Please log in to upload a profile picture.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 20),
                    Text('User doodoos:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if(doodooList.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: doodooList.length,
                        itemBuilder: (context, index) {
                          final doodoo = doodooList[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                doodoo['file_url'] ?? 'https://via.placeholder.com/150',
                              ),
                            ),
                            title: Text(doodoo['file_name'] ?? 'No name'),
                            subtitle: Text(
                              'Uploaded on: ${doodoo['created_at'] ?? 'Unknown date'}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final response = await _supabaseService
                                    .deleteDoodoo(doodoo['id']);
                                if (response) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Doodoo deleted successfully!'),
                                    ),
                                  );
                                  _loadUserDoodoos(); // Refresh the list
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to delete doodoo'),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    )
                ],
              ),
            ),
        ),
      ),
    );
  }
}
