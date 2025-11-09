class GigDto {
  final String title;
  final String description;
  final String? category;
  final String? image;
  final List<String> tags;
  final double? price;
  final String? sellerId;

  const GigDto({
    required this.title,
    required this.description,
    this.category,
    this.image,
    this.tags = const [],
    this.price,
    this.sellerId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category ?? '',
        'image': image ?? '',
        'tags': tags,
        if (price != null) 'price': price,
        if (sellerId != null) 'sellerId': sellerId,
      };

  factory GigDto.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return GigDto(
        title: (json['title'] ?? '') as String,
        description: (json['description'] ?? '') as String,
        category: json['category'] as String?,
        image: json['image'] as String?,
        tags: json['tags'] is List
            ? (json['tags'] as List).map((e) => e.toString()).toList()
            : [],
        price: json['price'] != null ? (json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString())) : null,
        sellerId: json['sellerId']?.toString(),
      );
    }
    throw Exception('Invalid JSON format for GigDto');
  }
}

