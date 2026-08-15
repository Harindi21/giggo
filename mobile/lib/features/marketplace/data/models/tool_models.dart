/// A tool/equipment listing in the marketplace (P10).
class Tool {
  final String id;
  final String slug;
  final String name;
  final String category;
  final String? brand;
  final String description;
  final double price;
  final String currency;
  final String? imageUrl;
  final bool available;

  const Tool({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    this.brand,
    required this.description,
    required this.price,
    required this.currency,
    this.imageUrl,
    required this.available,
  });

  factory Tool.fromJson(Map<String, dynamic> json) => Tool(
    id: json['id'] as String,
    slug: json['slug'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    brand: json['brand'] as String?,
    description: json['description'] as String,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'LKR',
    imageUrl: json['imageUrl'] as String?,
    available: json['available'] as bool? ?? true,
  );
}
