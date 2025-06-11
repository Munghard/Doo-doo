import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double userRating;
  final int? ratingCount;
  final ValueChanged<double>? onRatingUpdate;
  final bool showAverageRating;
  final bool showRatingInfo;

  const RatingWidget({
    super.key,
    required this.rating,
    required this.ratingCount,
    required this.userRating,
    this.onRatingUpdate,
    this.showAverageRating = false,
    this.showRatingInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text('Rate doodo:',
              //   style: Theme.of(context).textTheme.bodySmall,
              //   textAlign: TextAlign.center,
              // ),

              if(showRatingInfo)
              if (ratingCount != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Ratings: $ratingCount, Avg: ${rating.toStringAsFixed(1)}',
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: RatingBar.builder(
                  initialRating: userRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Text(
                    '💩',
                    style: TextStyle(
                      fontSize: 24, // Reduced from 32 to 24
                      fontFamily: 'Roboto',
                      fontFamilyFallback: ['Noto Color Emoji'],
                    ),
                  ),
                  onRatingUpdate: onRatingUpdate ?? (_) {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
