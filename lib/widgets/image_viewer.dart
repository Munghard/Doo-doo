import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String? imageUrl;
  final String? imageName;
  final String? postedBy;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;
  final bool showNavigation; // Flag to control navigation visibility
  final int? ratingCount; // New property to display the number of ratings

  const ImageViewer({
    super.key,
    required this.imageUrl,
    required this.imageName,
    required this.postedBy,
    this.onNext,
    this.onPrev,
    this.showNavigation = true, // Default to true
    this.ratingCount, // Optional property
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                if (showNavigation)
                  ElevatedButton(
                    onPressed: onPrev,
                    child: const Icon(Icons.arrow_back),
                  ),
                const SizedBox(width: 10),
                SizedBox(
                  height: constraints.maxHeight * 0.8, // Use 80% of the allocated height
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.brown, width: 4)),
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(imageUrl!, fit: BoxFit.contain)
                        : const Center(child: Text('No images available')),
                  ),
                ),
                const SizedBox(width: 10),
                if (showNavigation)
                  ElevatedButton(
                    onPressed: onNext,
                    child: const Icon(Icons.arrow_forward),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (ratingCount != null)
              Text(
                'Number of ratings: $ratingCount',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
          ],
        );
      },
    );
  }
}
