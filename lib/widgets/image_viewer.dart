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

  Widget _buildImage(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Center(child: Text('No images available'));
    }
    return Image.network(
      imageUrl!,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image, size: 48)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Text(
              imageName ?? 'No image selected',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < -500) {
                    onPrev!();
                  } else if (details.primaryVelocity! > 500) {
                    onNext!();
                  }
                },
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      insetPadding: const EdgeInsets.all(10),
                      child: InteractiveViewer(
                        child: _buildImage(context),
                      ),
                    ),
                  );
                },
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.brown, width: 4)),
                    clipBehavior: Clip.hardEdge,
                    child: _buildImage(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By user: ${postedBy ?? 'Anon'}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (showNavigation) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onPrev,
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: onNext,
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}