// Service taxonomy models (categories and their skills).

class Category {
  final String id;
  final String name;
  final String? description;

  const Category({required this.id, required this.name, this.description});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
  );
}

class Skill {
  final String id;
  final String categoryId;
  final String name;

  const Skill({required this.id, required this.categoryId, required this.name});

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json['id'] as String,
    categoryId: json['categoryId'] as String,
    name: json['name'] as String,
  );
}
