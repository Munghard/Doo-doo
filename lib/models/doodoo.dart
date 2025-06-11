class DoodooEntry {
  final int id;
  final String fileName;
  final String fileUrl;
  final double rating;
  final Map<String, dynamic> userProfile;
  final DateTime createdAt;
  final List<String> comments;
  final int numComments;
  final int numRatings;
  double userRating;

  DoodooEntry({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.rating,
    required this.userProfile,
    required this.createdAt,
    required this.comments,
    required this.numComments,
    required this.numRatings,
    required this.userRating,
  });
}