import 'package:flutter/material.dart';
import '../shared/gig_card.dart';
import 'gig_viewmodel.dart';
import 'seller_gig_detail_screen.dart';
import '../shared/gigs_top_bar.dart';

class SellerMyGigsScreen extends StatelessWidget {
  final GigViewModel vm;

  const SellerMyGigsScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GigsTopBar(title: 'My Gigs'),
      body: AnimatedBuilder(
        animation: vm,
        builder: (_, __) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(child: Text(vm.error!));
          }

          if (vm.gigs.isEmpty) {
            return const Center(child: Text("No hay gigs creados aún"));
          }

          // ✔ EXACTO COMO ANDROID: LISTA VERTICAL
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.gigs.length,
            itemBuilder: (_, index) {
              final gig = vm.gigs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GigCard(
                  gig: gig,
                  isSeller: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SellerGigDetailScreen(gig: gig),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
