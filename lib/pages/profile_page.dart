import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:doodoo/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseService _supabaseService = SupabaseService();
  String? profilePictureUrl;
  String? userEmail;
  String? userName;
  int totalDoodoos = 0;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  List<Map<String, dynamic>> userDoodoos = []; // Add this line

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadProfile(widget.userId);
    _loadUserDoodoos(); // Add this line
  }

  Future<void> _checkLoginStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _isLoggedIn = user != null;
    });
  }

  Future<void> _loadProfile(String? userId) async {
  // Validate userId before querying
  final validUserId = userId ?? Supabase.instance.client.auth.currentUser?.id;
  if (validUserId == null || validUserId.isEmpty) {
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
        .eq('id', validUserId)
        .single();

    final count = await _supabaseService.getTotalDoodoosByUser(validUserId);

    setState(() {
      profilePictureUrl = response['profile_picture'] as String?;
      userName = response['user_name'] as String? ?? 'No username found';
      totalDoodoos = count;
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('Error loading profile: $e');
    setState(() {
      profilePictureUrl = null;
      totalDoodoos = 0;
      userName = 'No username found';
      _isLoading = false;
    });
  }
}

  Future<void> _uploadProfilePicture(String? userId) async {
    // Only allow changing own profile picture
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (widget.userId != null && widget.userId != currentUserId) return;
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
      await _loadProfile(userId); // Reload profile to update the picture
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

  // Add this method to fetch user's doodoos
  Future<void> _loadUserDoodoos() async {
  final userId = widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
  if (userId == null || userId.isEmpty) return;
  try {
    final response = await Supabase.instance.client
        .from('files')
        .select('id, file_name, created_at, file_url')
        .eq('posted_by', userId)
        .order('created_at', ascending: false);
    setState(() {
      userDoodoos = List<Map<String, dynamic>>.from(response);
    });
  } catch (e) {
    debugPrint('Error loading user doodoos: $e');
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.all(16),
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
                    // Only show upload button if viewing own profile
                    if (_isLoggedIn && (widget.userId == null || widget.userId == Supabase.instance.client.auth.currentUser?.id)) ...[
                      const Text(
                        'Change profile picture by uploading a file below:',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:() => _uploadProfilePicture(widget.userId),
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
                    const Text(
                      'User Doodoos:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (userDoodoos.isEmpty)
                      const Center(child: Text('No doodoos found.'))
                    else
                      ...userDoodoos.map((doodoo) => ListTile(
                            leading: (doodoo['file_url'] != null && doodoo['file_url'].toString().isNotEmpty)
                                ? Image.network(
                                    doodoo['file_url'],
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image_not_supported, size: 56),
                            title: Text(doodoo['file_name'] ?? 'No name'),
                            subtitle: Text(
                              doodoo['created_at'] != null
                                  ? doodoo['created_at'].toString().split('T').first
                                  : '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete doodoo',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Doodoo'),
                                    content: const Text('Are you sure you want to delete this doodoo?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  final success = await _supabaseService.deleteDoodoo(doodoo['id']);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Doodoo deleted!')),
                                    );
                                    await _loadUserDoodoos();
                                    setState(() {
                                      totalDoodoos = totalDoodoos > 0 ? totalDoodoos - 1 : 0;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed to delete doodoo')),
                                    );
                                  }
                                }
                              },
                            ),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}
