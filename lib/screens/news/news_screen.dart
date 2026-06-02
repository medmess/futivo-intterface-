import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../models/news_ad.dart';
import '../../models/sports_news_article.dart';
import '../../services/sports_news_service.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _service = SportsNewsService();
  final _searchController = TextEditingController();
  late Future<_NewsFeedData> _future;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = _loadFeed();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _future = _loadFeed());
    await _future;
  }

  Future<_NewsFeedData> _loadFeed() async {
    final results = await Future.wait([
      _service.fetchLatest(),
      _service.fetchNewsAds(),
    ]);

    return _NewsFeedData(
      articles: results[0] as List<SportsNewsArticle>,
      ads: results[1] as List<NewsAd>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientTop, AppColors.gradientBottom],
        ),
      ),
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _refresh,
        child: FutureBuilder<_NewsFeedData>(
          future: _future,
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState != ConnectionState.done &&
                !snapshot.hasData;
            final data = snapshot.data ?? const _NewsFeedData();
            final articles = data.articles;
            final ads = data.ads;
            final visibleArticles = _search(articles);
            final feedItems = _buildFeedItems(visibleArticles, ads);
            final featured = visibleArticles.take(5).toList();
            final notificationArticle = featured.isNotEmpty
                ? featured.first
                : null;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _NewsMasthead(),
                        const SizedBox(height: 16),
                        const _NewsTournamentStats(),
                        const SizedBox(height: 16),
                        if (featured.isNotEmpty)
                          _FeaturedCarousel(articles: featured),
                        const SizedBox(height: 18),
                        if (notificationArticle != null) ...[
                          _NotificationPreview(article: notificationArticle),
                          const SizedBox(height: 14),
                        ],
                        _SearchField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() => searchQuery = value.trim());
                          },
                        ),
                        const SizedBox(height: 18),
                        _SectionTitle(
                          title: searchQuery.isEmpty
                              ? context.t('newsAll')
                              : context.t('newsSearchResults'),
                          count: visibleArticles.length,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 28),
                      child: _NewsLoadingState(),
                    ),
                  )
                else if (visibleArticles.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 28),
                      child: _EmptySearchState(),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                    sliver: SliverList.separated(
                      itemCount: feedItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = feedItems[index];
                        return _StaggeredFadeIn(
                          index: index,
                          child: item.ad == null
                              ? _FeedArticleCard(
                                  article: item.article!,
                                  rank: item.articleRank!,
                                  onTap: () => _openArticle(
                                    context,
                                    item.article!,
                                    item.articleRank,
                                  ),
                                )
                              : _NewsAdCard(ad: item.ad!),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_NewsFeedItem> _buildFeedItems(
    List<SportsNewsArticle> articles,
    List<NewsAd> ads,
  ) {
    if (ads.isEmpty) {
      return [
        for (var i = 0; i < articles.length; i++)
          _NewsFeedItem.article(articles[i], i + 1),
      ];
    }

    final items = <_NewsFeedItem>[];
    for (var i = 0; i < articles.length; i++) {
      items.add(_NewsFeedItem.article(articles[i], i + 1));
      if ((i + 1) % 5 == 0) {
        final ad = ads[((i + 1) ~/ 5 - 1) % ads.length];
        items.add(_NewsFeedItem.ad(ad));
      }
    }
    return items;
  }

  List<SportsNewsArticle> _search(List<SportsNewsArticle> articles) {
    final query = searchQuery.toLowerCase();
    if (query.isEmpty) return articles;
    return articles.where((article) {
      final text = '${article.title} ${article.summary} ${article.source}'
          .toLowerCase();
      return text.contains(query);
    }).toList();
  }

  void _openArticle(
    BuildContext context,
    SportsNewsArticle article,
    int? rank,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsDetailScreen(article: article, rank: rank),
      ),
    );
  }
}

class _NewsFeedData {
  final List<SportsNewsArticle> articles;
  final List<NewsAd> ads;

  const _NewsFeedData({
    this.articles = const <SportsNewsArticle>[],
    this.ads = const <NewsAd>[],
  });
}

class _NewsFeedItem {
  final SportsNewsArticle? article;
  final NewsAd? ad;
  final int? articleRank;

  const _NewsFeedItem.article(this.article, this.articleRank) : ad = null;

  const _NewsFeedItem.ad(this.ad) : article = null, articleRank = null;
}

class _StaggeredFadeIn extends StatelessWidget {
  final int index;
  final Widget child;

  const _StaggeredFadeIn({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index.clamp(0, 8) * 45)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _NewsMasthead extends StatelessWidget {
  const _NewsMasthead();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/futivo_logo.png',
                width: compact ? 40 : 46,
                height: compact ? 40 : 46,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('newsroomTitle'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 20 : 24,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    context.t('newsroomSubtitle'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (!compact) ...[const SizedBox(width: 8), const _LiveBadge()],
          ],
        );
      },
    );
  }
}

class _NewsTournamentStats extends StatelessWidget {
  const _NewsTournamentStats();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 370;
        final children = [
          _NewsStatTile(
            icon: Icons.account_tree_rounded,
            label: context.t('groups'),
            value: '12',
          ),
          _NewsStatTile(
            icon: Icons.flag_rounded,
            label: context.t('teams'),
            value: '48',
          ),
          _NewsStatTile(
            icon: Icons.public_rounded,
            label: context.t('hosts'),
            value: '3',
          ),
        ];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: AppColors.cupRed.withValues(alpha: 0.20),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: compact
              ? Column(
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      children[i],
                      if (i != children.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                )
              : Row(
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      Expanded(child: children[i]),
                      if (i != children.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _NewsStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _NewsStatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cupGreen.withValues(alpha: 0.34)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 18,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  final List<SportsNewsArticle> articles;

  const _FeaturedCarousel({required this.articles});

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  final _controller = PageController(viewportFraction: 0.86);
  int currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 408,
          child: PageView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.articles.length,
            onPageChanged: (index) => setState(() => currentIndex = index),
            itemBuilder: (context, index) {
              final article = widget.articles[index];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  var scale = 1.0;
                  if (_controller.position.haveDimensions) {
                    final page =
                        _controller.page ?? _controller.initialPage.toDouble();
                    scale = (1 - (page - index).abs() * 0.08).clamp(0.90, 1.0);
                  }
                  return Transform.translate(
                    offset: Offset(0, (1 - scale) * 80),
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.articles.length - 1 ? 0 : 10,
                  ),
                  child: _FeaturedArticleCard(
                    article: article,
                    index: index,
                    total: widget.articles.length,
                    onTap: () {
                      final state = context
                          .findAncestorStateOfType<_NewsScreenState>();
                      state?._openArticle(context, article, index + 1);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.articles.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == currentIndex ? 34 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == currentIndex
                      ? AppColors.cupRed
                      : AppColors.cupGreen.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  final SportsNewsArticle article;
  final int index;
  final int total;
  final VoidCallback onTap;

  const _FeaturedArticleCard({
    required this.article,
    required this.index,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _ArticleBackground(
        article: article,
        height: 408,
        borderRadius: 26,
        glow: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TechPill(
                    text: '${context.t('featuredNews')} ${index + 1}/$total',
                  ),
                  const Spacer(),
                  _SourceBadge(text: article.source),
                ],
              ),
              const Spacer(),
              _ArticleTextPanel(
                title: article.title,
                summary: article.summary,
                large: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationPreview extends StatelessWidget {
  final SportsNewsArticle article;

  const _NotificationPreview({required this.article});

  @override
  Widget build(BuildContext context) {
    final direction = _textDirectionFor(article.title);
    final align = _textAlignFor(article.title);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primaryGlow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  textDirection: direction,
                  textAlign: align,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  article.summary,
                  textDirection: direction,
                  textAlign: align,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
        suffixIcon: const Icon(Icons.tune_rounded, color: Colors.white38),
        hintText: context.t('newsSearchHint'),
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _TechPill(text: '$count ${context.t('articlesCount')}', compact: true),
      ],
    );
  }
}

class _FeedArticleCard extends StatelessWidget {
  final SportsNewsArticle article;
  final int rank;
  final VoidCallback onTap;

  const _FeedArticleCard({
    required this.article,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final direction = _textDirectionFor(article.title);
    final align = _textAlignFor(article.title);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 118,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 108,
                  height: 118,
                  child: _ArticleImage(article: article),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              article.source,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.primaryGlow,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            '#$rank',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.28),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.title,
                        textDirection: direction,
                        textAlign: align,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            _date(article.publishedAt),
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsAdCard extends StatelessWidget {
  final NewsAd ad;

  const _NewsAdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 238,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            ad.imageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/futivo_news_hero.png',
                fit: BoxFit.cover,
              );
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.08),
                  AppColors.background.withValues(alpha: 0.64),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AdBadge(),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (ad.subtitle?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 7),
                        Text(
                          ad.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.76),
                            fontSize: 12.5,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdBadge extends StatelessWidget {
  const _AdBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        context.t('sponsored'),
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ArticleBackground extends StatelessWidget {
  final SportsNewsArticle article;
  final double height;
  final double borderRadius;
  final bool glow;
  final Widget child;

  const _ArticleBackground({
    required this.article,
    required this.height,
    required this.borderRadius,
    required this.child,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glow
              ? AppColors.cupRed.withValues(alpha: 0.32)
              : Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: (glow ? AppColors.cupRed : Colors.black).withValues(
              alpha: glow ? 0.30 : 0.30,
            ),
            blurRadius: glow ? 34 : 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ArticleImage(article: article),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.02),
                  AppColors.background.withValues(alpha: 0.18),
                  AppColors.background.withValues(alpha: 0.58),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ArticleImage extends StatelessWidget {
  final SportsNewsArticle article;

  const _ArticleImage({required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset('assets/futivo_news_hero.png', fit: BoxFit.cover);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/futivo_news_hero.png',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        );
      },
    );
  }
}

class _ArticleTextPanel extends StatelessWidget {
  final String title;
  final String summary;
  final String? date;
  final bool large;
  final bool expanded;

  const _ArticleTextPanel({
    required this.title,
    required this.summary,
    this.date,
    this.large = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final direction = _textDirectionFor('$title $summary');
    final align = _textAlignFor('$title $summary');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(large ? 16 : 15),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (date != null) ...[
            Text(
              date!,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            title,
            textDirection: direction,
            textAlign: align,
            maxLines: large ? 3 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: large ? 23 : 19,
              height: 1.16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            summary,
            textDirection: direction,
            textAlign: align,
            maxLines: large
                ? 5
                : expanded
                ? 7
                : 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: large ? 13.5 : 13,
              height: 1.42,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE84A5F).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: const Color(0xFFE84A5F).withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fiber_manual_record,
            color: Color(0xFFE84A5F),
            size: 10,
          ),
          const SizedBox(width: 6),
          Text(
            context.t('live'),
            style: const TextStyle(
              color: Color(0xFFE84A5F),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TechPill extends StatelessWidget {
  final String text;
  final bool compact;

  const _TechPill({required this.text, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.24)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.gold,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String text;

  const _SourceBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.22)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.teal,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NewsLoadingState extends StatelessWidget {
  const _NewsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
              backgroundColor: Colors.white12,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _loadingNewsText(context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _loadingNewsText(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'en' => 'Loading latest football news...',
    'ar' =>
      '\u062c\u0627\u0631\u064a \u062a\u062d\u0645\u064a\u0644 \u0622\u062e\u0631 \u0623\u062e\u0628\u0627\u0631 \u0643\u0631\u0629 \u0627\u0644\u0642\u062f\u0645...',
    _ => 'Chargement des dernieres news football...',
  };
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.manage_search_rounded,
            color: AppColors.primary,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            context.t('noArticlesFound'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            context.t('tryAnotherNewsSearch'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _date(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

bool _hasArabic(String value) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
}

TextDirection _textDirectionFor(String value) {
  return _hasArabic(value) ? TextDirection.rtl : TextDirection.ltr;
}

TextAlign _textAlignFor(String value) {
  return _hasArabic(value) ? TextAlign.right : TextAlign.left;
}
