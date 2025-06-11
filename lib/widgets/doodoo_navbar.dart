import 'package:doodoo/pages/home_page.dart';
import 'package:doodoo/pages/notifications_page.dart';
import 'package:doodoo/pages/scroll_doodoos_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doodoo/pages/profile_page.dart';
import 'package:doodoo/pages/login_page.dart';
import 'package:doodoo/pages/register_page.dart';
import 'package:doodoo/pages/poop_of_the_day.dart';
import 'package:doodoo/services/supabase_service.dart';

class DoodooNavBar extends StatefulWidget {
  final VoidCallback onAddFile;
  final VoidCallback? onReload;

  const DoodooNavBar({
    Key? key, // <-- add this
    required this.onAddFile,
    this.onReload,
  }) : super(key: key); // <-- pass to super

  @override
  State<DoodooNavBar> createState() => _DoodooNavBarState();
}

class _DoodooNavBarState extends State<DoodooNavBar> {
  final SupabaseService _supabaseService = SupabaseService();
  String username = 'Guest';
  String? profilePictureUrl;
  String? email;
  bool _loading = true;
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        username = 'Guest';
        profilePictureUrl = null;
        email = null;
        _loading = false;
        notificationCount = 0;
      });
      return;
    }
    try {
      notificationCount = await _supabaseService.getTotalNotificationsByUser(user.id);
      final data = await Supabase.instance.client
          .from('profiles')
          .select('user_name ,profile_picture')
          .eq('id', user.id)
          .single();
      setState(() {
        profilePictureUrl = data['profile_picture'] as String?;
        username = data['user_name'] as String? ?? 'Guest';
        email = user.email;
        _loading = false;
        
      });
    } catch (e) {
      setState(() {
        email = user.email;
        username = user.email?.split('@')[0] ?? 'Guest';
        profilePictureUrl = null;
        _loading = false;
        notificationCount = 0; // Reset notification count
      });
    }
  }

  String getShortEmail(String? email, {int maxLength = 6}) {
    if (email == null) return '';
    final username = email.contains('@') ? email.split('@')[0] : email;
    if (username.length <= maxLength) return username;
    return '${username.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;
    if (_loading) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (profilePictureUrl != null && profilePictureUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              profilePictureUrl!,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/default-user.jpg',
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            username,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        // Add file button - always visible
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Take a doo-doo',
          onPressed: widget.onAddFile,
        ),
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Home',
          onPressed:  () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ScrollDoodoosPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.list),
          tooltip: 'Scroll doo-doos',
          onPressed:  () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.star),
          tooltip: 'Doodoo of the Day',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PoopOfTheDayPage()),
            );
          },
        ),
        if (isLoggedIn)
          IconButton(
            icon: const Icon(Icons.person_2),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userId: user.id),
                ),
              );
            },
          ),
        Stack(
          children: [
            IconButton(
              icon:const Icon(Icons.notifications),
              tooltip: 'Notifications',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsPage(userId: user?.id),
                  ),
                );
                // Call reload after returning from notifications
                if (widget.onReload != null) {
                  widget.onReload!();
                }
              },
            ),
            if(notificationCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$notificationCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        if (!isLoggedIn)
          IconButton(
            icon: const Icon(Icons.app_registration_outlined),
            tooltip: 'Register',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterPage(title: 'Register'),
                ),
              );
            },
          ),
        if (!isLoggedIn)
          IconButton(
            icon: const Icon(Icons.login_outlined),
            tooltip: 'Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(title: 'Login'),
                ),
              );
            },
          ),
        if (isLoggedIn)
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(),
                ),
              );
            },
          ),
      ],
    );
  }
}
