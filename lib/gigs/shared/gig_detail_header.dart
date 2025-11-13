import 'package:flutter/material.dart';
import '../domain/model/gig.dart';

class GigDetailHeader extends StatelessWidget {
  final Gig gig;

  const GigDetailHeader({super.key, required this.gig});

  @override
  Widget build(BuildContext context) {
    final img = gig.image ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: img.isNotEmpty
              ? Image.network(img, height: 250, width: double.infinity, fit: BoxFit.cover)
              : Container(
            height: 250,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 60),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          gig.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 8),

        Text(
          "Seller ID: ${gig.sellerId ?? '-'}",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
