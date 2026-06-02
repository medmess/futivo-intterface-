class SportsNewsArticle {
  final String title;
  final String source;
  final String summary;
  final String? imageUrl;
  final String? url;
  final DateTime publishedAt;
  final bool manual;

  const SportsNewsArticle({
    required this.title,
    required this.source,
    required this.summary,
    required this.publishedAt,
    this.imageUrl,
    this.url,
    this.manual = false,
  });
}
