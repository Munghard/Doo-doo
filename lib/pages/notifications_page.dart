import 'package:doodoo/pages/home_page.dart';
import 'package:doodoo/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsPage extends StatefulWidget {
  final String? userId;
  const NotificationsPage({super.key, this.userId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<dynamic>? _notifications;
  String? userName;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      loadData(widget.userId!);
    }
  }
  Future<void> markAllRead(String s) async {
    await _supabaseService.markAllNotificationsRead(widget.userId!);
    setState(() {
      _notifications?.forEach((notification) {
        notification['read'] = true; // Update the local state to reflect read status
      });
    });
  }

  Future<void> loadData(String userId) async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('profile_picture, user_name')
          .eq('id', userId)
          .single();

      final notifications = await Supabase.instance.client
          .from('notifications')
          .select('id, sender_id, file_id, data, type, read, created_at') // <-- add 'id'
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      for (var notification in notifications) {
        final data = notification['data'] as String;
        final senderId = notification['sender_id'] as String;
        final type = notification['type'] as String;

        final senderProfile = await Supabase.instance.client
            .from('profiles')
            .select('user_name, profile_picture, id')
            .eq('id', senderId)
            .maybeSingle();


        if (senderProfile != null) {
          notification['sender'] = senderProfile;
        }
      }

      setState(() {
        userName = profile['user_name'] as String?;
        _notifications = notifications as List<dynamic>;
        
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications for ${userName ?? "User"}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400.0, maxHeight: 600.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    markAllRead(widget.userId!);
                  },
                  child: const Text('Mark All as Read'),
                ),
                if (_notifications != null)
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: _notifications!.map((notification) {
                          final createdAt = notification['created_at'] != null
                              ? DateTime.parse(notification['created_at']).toLocal().toString()
                              : 'No Date';

                          final profilePic = notification['sender']?['profile_picture']?? '';
                          final senderName = notification['sender']?['user_name'] ?? 'Unknown Sender';
                          final read = notification['read'] == true;

                          return ListTile(
                            onTap: () async {
                              if (!read) {
                                await _supabaseService.markNotificationRead(
                                  widget.userId!,
                                  notification['id'] as int,
                                );
                                setState(() {
                                  notification['read'] = true;
                                });
                              }
                            },
                            title: Text('$senderName'),
                            subtitle: Text('New ${notification['type']}: ${notification['data'] ?? 'No Data'} \n$createdAt'),
                            trailing: !read
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.fiber_manual_record, color: Colors.grey, size: 18),
                                    SizedBox(width: 4),
                                  ],
                                )
                              : null, // No trailing widget when read is true
                            leading: CircleAvatar(
                              backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
                              child: profilePic == null ? const Icon(Icons.person) : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}
