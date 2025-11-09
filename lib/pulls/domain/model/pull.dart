enum PullState { pending, accepted, canceled }

class Pull {
  final int id;
  final int sellerId;
  final int buyerId;
  final int gigId;
  final double priceInit;
  final double priceUpdate;
  final PullState state;

  const Pull({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.gigId,
    required this.priceInit,
    required this.priceUpdate,
    required this.state,
  });
}

