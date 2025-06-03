import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ImageViewer extends StatelessWidget {
  final String? imageUrl;
  final String? imageName;
  final String? postedBy;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;
  final double rating;
  final ValueChanged<double>? onRatingUpdate;

  const ImageViewer({
    super.key,
    required this.imageUrl,
    required this.imageName,
    required this.postedBy,
    this.onNext,
    this.onPrev,
    required this.rating,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          imageName ?? 'No image selected',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          'By user: ${postedBy ?? 'Anon'}',
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onPrev,
              child: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 10),
            Container(
              constraints: BoxConstraints(maxWidth: 600, maxHeight: 600),
              decoration: BoxDecoration(border: Border.all(color: Colors.brown, width: 4)),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(imageUrl!, fit: BoxFit.cover)
                  : const Center(child: Text('No images available')),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onNext,
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Average rating: ${rating.toStringAsFixed(1)}',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Text(
            '💩',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Roboto',
              fontFamilyFallback: ['Noto Color Emoji'],
            ),
          ),
          onRatingUpdate: onRatingUpdate ?? (_) {},
        ),
      ],
    );
  }
}
