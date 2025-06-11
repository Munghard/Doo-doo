import 'package:doodoo/models/doodoo.dart';
import 'package:doodoo/widgets/rating_widget.dart';
import 'package:flutter/material.dart';
import 'package:doodoo/services/supabase_service.dart';
import 'package:doodoo/widgets/doodoo_navbar.dart';
import 'package:doodoo/pages/doodoo_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScrollDoodoosPage extends StatefulWidget {
  const ScrollDoodoosPage({super.key});

  @override
  State<ScrollDoodoosPage> createState() => _ScrollDoodoosPageState();
}

class _ScrollDoodoosPageState extends State<ScrollDoodoosPage> {
  final String title = '💩Doo-doo';
  final SupabaseService _supabaseService = SupabaseService();
  List<DoodooEntry> _doodoos = [];
  bool _isLoading = false;
  Key navbarKey = UniqueKey(); // Add this line

  @override
  void initState() {
    super.initState();
    _loadAllDoodoos();
  }

  Future<void> _loadAllDoodoos() async {
    setState(() => _isLoading = true);
    try {
      final doodoos = await _supabaseService.fetchFullDoodoos();
      debugPrint('Fetched doodoos: ${doodoos.length}');
      debugPrint('Fetched doodoos raw: $doodoos');
      if (doodoos.isNotEmpty) {
        debugPrint('First doodoo: ${doodoos.first}');
        debugPrint('fileUrl type: ${doodoos.first.fileUrl.runtimeType}');
        debugPrint('fileName type: ${doodoos.first.fileName.runtimeType}');
      } else {
        debugPrint('No doodoos returned from fetchFullDoodoos');
      }
      setState(() {
        _doodoos = doodoos;
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Error loading images: $e');
      debugPrint('Stack: $stack');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshUserRating(String userId,int fileId) async {}



  Future<void> _refreshAll() async {
    await _loadAllDoodoos();
    setState(() {
      navbarKey = UniqueKey(); // Force navbar to rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: InkWell(
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontFamilyFallback: ['Noto Color Emoji'],
            ),
          ),
        ),
        actions: [
          DoodooNavBar(
            key: navbarKey, // Pass the key to force rebuild
            onAddFile: () {}, // You can wire this up if needed
            onReload: _refreshAll, // <-- add this
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _doodoos.isEmpty
                      ? const Center(child: Text('No doodoos available.'))
                      : ListView.builder(
                          itemCount: _doodoos.length,
                          itemBuilder: (context, index) {
                            final doodoo = _doodoos[index];

                            final fileUrl = doodoo.fileUrl.toString();
                            final fileName = doodoo.fileName.toString();
                            final userProfile = doodoo.userProfile;
                            final userName = userProfile['user_name']?.toString() ?? '';
                            final profilePic = userProfile['profile_picture']?.toString() ?? '';

                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoodooPage(doodooId: doodoo.id),
                                  ),
                                );
                                // Reload after returning from DoodooPage
                                // should just update the rating bar if rating was changed
                                
                                // _refreshAll();
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                // color: Colors.grey[50],
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          profilePic.isNotEmpty
                                              ? CircleAvatar(
                                                  radius: 18,
                                                  backgroundImage: NetworkImage(profilePic),
                                                  backgroundColor: Colors.transparent,
                                                )
                                              : CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: Colors.brown[200],
                                                  child: Text(
                                                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              userName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            doodoo.createdAt.toString().split('T').first,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                                        decoration: BoxDecoration(
                                          
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          fileName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final imageSize = constraints.maxWidth;
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child:Container(
                                              color: Theme.of(context).colorScheme.surfaceContainerLowest,
                                             child: Image.network(
                                              fileUrl,
                                              width: imageSize,
                                              height: imageSize,
                                              fit: BoxFit.contain,
                                              
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      // Ratings row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [

                                          
                                      
                                      Row(
                                        children: [
                                          const Text(
                                            '💩',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(width: 6),
                                          Tooltip(
                                            message: 'Average rating',
                                            child: const SizedBox.shrink(),
                                          ),
                                          Text(
                                            doodoo.rating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Comments row
                                      Row(
                                        children: [
                                          Icon(Icons.comment, size: 20, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            doodoo.numComments.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Stars row
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 20, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            doodoo.numRatings.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                        ],
                                      ),
                                      if (Supabase.instance.client.auth.currentUser != null) ...[
                                        const SizedBox(height: 8),
                                        RatingWidget(
                                          userRating: doodoo.userRating,
                                          rating: doodoo.rating.toDouble(),
                                          ratingCount: doodoo.numRatings,
                                          onRatingUpdate: (rating) {
                                            _supabaseService.addRating(
                                              doodoo.id,
                                              rating,
                                              Supabase.instance.client.auth.currentUser?.id ?? '',
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Rating updated to $rating'),
                                                duration: const Duration(seconds: 2),
                                              )
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
      ),
    );
  }
}
