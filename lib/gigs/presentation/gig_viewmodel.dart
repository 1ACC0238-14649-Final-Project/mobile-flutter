import 'package:flutter/material.dart';
import '../data/repository/gig_repository.dart';
import '../domain/model/gig.dart';

class GigViewModel extends ChangeNotifier {
  final GigRepository repo;

  GigViewModel({GigRepository? repository})
      : repo = repository ?? GigRepository();

  List<Gig> gigs = [];
  bool loading = false;
  String? error;

  Future<void> loadMyGigs(int sellerId) async {
    loading = true;
    notifyListeners();

    try {
      gigs = await repo.getGigsBySeller(sellerId);
      error = null;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}