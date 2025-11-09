class Gig {
  final int? id;
  final String title;
  final String description;
  final String? category;
  final String? image;
  final List<String> tags;
  final int? sellerId;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final bool? isActive;

  const Gig({
    this.id,
    required this.title,
    required this.description,
    this.category,
    this.image,
    this.tags = const [],
    this.sellerId,
    this.createdDate,
    this.modifiedDate,
    this.isActive,
  });
}

