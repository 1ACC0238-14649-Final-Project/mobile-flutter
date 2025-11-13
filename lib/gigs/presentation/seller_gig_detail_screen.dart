import 'package:flutter/material.dart';
import '../shared/gig_detail_header.dart';
import '../domain/model/gig.dart';
import '../shared/gigs_top_bar.dart';
import '../shared/primary_button.dart';

class SellerGigDetailScreen extends StatelessWidget {
  final Gig gig;

  const SellerGigDetailScreen({super.key, required this.gig});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GigsTopBar(title: "Gig Details"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GigDetailHeader(gig: gig),

            const SizedBox(height: 20),

            Text("Description", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(gig.description),

            if (gig.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text("Tags:", style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: gig.tags
                    .map((t) => Chip(label: Text(t)))
                    .toList(),
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: "Editar Gig",
              onPressed: () {
                // Navegación al editor
              },
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                // TODO: eliminar gig
              },
              child: const Text(
                "Eliminar Gig",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
