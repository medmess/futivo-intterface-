class NewsAd {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? targetUrl;
  final bool isActive;

  const NewsAd({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.subtitle,
    this.targetUrl,
    this.isActive = true,
  });
}
