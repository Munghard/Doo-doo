import 'package:flutter/material.dart';
// Import other dependencies as needed

class DoodooNavBar extends StatelessWidget {
  final String? profilePictureUrl;
  final String shortEmail;
  final VoidCallback onAddFile;
  final VoidCallback onPoopOfTheDay;
  final VoidCallback? onProfile;
  final VoidCallback? onRegister;
  final VoidCallback? onLogin;
  final VoidCallback? onLogout;
  final bool isLoggedIn;

  const DoodooNavBar({
    super.key,
    required this.profilePictureUrl,
    required this.shortEmail,
    required this.onAddFile,
    required this.onPoopOfTheDay,
    this.onProfile,
    this.onRegister,
    this.onLogin,
    this.onLogout,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
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
            shortEmail,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Take a doo-doo',
          onPressed: onAddFile,
        ),
        IconButton(
          icon: const Icon(Icons.star),
          tooltip: 'Doodoo of the Day',
          onPressed: onPoopOfTheDay,
        ),
        if (isLoggedIn && onProfile != null)
          IconButton(
            icon: const Icon(Icons.person_2),
            tooltip: 'Profile',
            onPressed: onProfile,
          ),
        if (!isLoggedIn && onRegister != null)
          IconButton(
            icon: const Icon(Icons.app_registration_outlined),
            tooltip: 'Register',
            onPressed: onRegister,
          ),
        if (!isLoggedIn && onLogin != null)
          IconButton(
            icon: const Icon(Icons.login_outlined),
            tooltip: 'Login',
            onPressed: onLogin,
          ),
        if (isLoggedIn && onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: onLogout,
          ),
      ],
    );
  }
}
