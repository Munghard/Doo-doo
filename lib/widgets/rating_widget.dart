import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingUpdate;

  const RatingWidget({
    super.key,
    required this.rating,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
      },
    );
  }
}
