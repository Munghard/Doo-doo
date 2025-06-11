import 'package:doodoo/pages/doodoo_page.dart';
import 'package:doodoo/pages/profile_page.dart';
import 'package:doodoo/pages/scroll_doodoos_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://urnlhjuzszdcrvouqctd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVybmxoanV6c3pkY3J2b3VxY3RkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3Nzk5NjUsImV4cCI6MjA2NDM1NTk2NX0.7s-yOYI-Q7Wxepycj7A2jGrYpLJg1J_XlE3viHqQVv0',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doo-doo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 134, 87, 0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ScrollDoodoosPage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/profile') {
          final userId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => ProfilePage(userId: userId),
          );
        }
        if (settings.name == '/doodoo_details') {
          final args = settings.arguments as Map<String, dynamic>;
          final doodooId = args['doodooId'] as int;
          return MaterialPageRoute(
            builder: (context) => DoodooPage(doodooId: doodooId),
          );
        }
        return null;
      },
    );
  }
}
