import '../../domain/model/pull.dart';

class PullDto {
  final int id;
  final int sellerId;
  final int buyerId;
  final int gigId;
  final double priceInit;
  final double priceUpdate;
  final String state;

  const PullDto({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.gigId,
    required this.priceInit,
    required this.priceUpdate,
    required this.state,
  });

  Pull toDomain() {
    return Pull(
      id: id,
      sellerId: sellerId,
      buyerId: buyerId,
      gigId: gigId,
      priceInit: priceInit,
      priceUpdate: priceUpdate,
      state: _parseState(state),
    );
  }

  PullState _parseState(String state) {
    switch (state.toLowerCase()) {
      case 'pending':
        return PullState.pending;
      case 'accepted':
        return PullState.accepted;
      case 'canceled':
        return PullState.canceled;
      default:
        return PullState.pending;
    }
  }

  factory PullDto.fromJson(Map<String, dynamic> json) {
    return PullDto(
      id: json['id'] as int,
      sellerId: json['sellerId'] as int,
      buyerId: json['buyerId'] as int,
      gigId: json['gigId'] as int,
      priceInit: (json['priceInit'] as num).toDouble(),
      priceUpdate: (json['priceUpdate'] as num).toDouble(),
      state: json['state'] as String,
    );
  }
}

