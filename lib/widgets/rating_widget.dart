import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int? ratingCount;
  final ValueChanged<double>? onRatingUpdate;
  final bool showAverageRating;

  const RatingWidget({
    super.key,
    required this.rating,
    required this.ratingCount,
    this.onRatingUpdate,
    this.showAverageRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (ratingCount != null) ...[
              const SizedBox(height: 10),
              Text(
                'Number of ratings: $ratingCount',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if(showAverageRating)
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
              allowHalfRating: false,
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
      },
    );
  }
}
