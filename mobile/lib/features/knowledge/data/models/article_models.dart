/// A Knowledge Hub article (P9). `content` is present on the detail response
/// and null in list summaries.
class Article {
  final String id;
  final String slug;
  final String title;
  final String category;
  final String excerpt;
  final String? content;
  final String? coverImageUrl;
  final String authorName;
  final DateTime? publishedAt;

  const Article({
    required this.id,
    required this.slug,
    required this.title,
    required this.category,
    required this.excerpt,
    this.content,
    this.coverImageUrl,
    required this.authorName,
    this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    id: json['id'] as String,
    slug: json['slug'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    excerpt: json['excerpt'] as String,
    content: json['content'] as String?,
    coverImageUrl: json['coverImageUrl'] as String?,
    authorName: json['authorName'] as String? ?? 'GIGGO Team',
    publishedAt: json['publishedAt'] != null
        ? DateTime.tryParse(json['publishedAt'] as String)
        : null,
  );
}
