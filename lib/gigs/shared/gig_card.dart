import 'package:flutter/material.dart';
import '../domain/model/gig.dart';

class GigCard extends StatelessWidget {
  final Gig gig;
  final VoidCallback onTap;
  final bool isSeller;

  const GigCard({
    super.key,
    required this.gig,
    required this.onTap,
    this.isSeller = false,
  });

  @override
  Widget build(BuildContext context) {
    final img = gig.image ?? "";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: img.isNotEmpty
                  ? Image.network(img, height: 130, width: double.infinity, fit: BoxFit.cover)
                  : Container(
                height: 130,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                gig.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: isSeller
                  ? const Text("Tu gig publicado", style: TextStyle(color: Colors.blueGrey, fontSize: 12))
                  : Text(
                gig.category ?? (gig.tags.isNotEmpty ? gig.tags.first : "Gig"),
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
