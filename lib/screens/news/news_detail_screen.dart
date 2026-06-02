import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../models/sports_news_article.dart';

class NewsDetailScreen extends StatelessWidget {
  final SportsNewsArticle article;
  final int? rank;

  const NewsDetailScreen({super.key, required this.article, this.rank});

  @override
  Widget build(BuildContext context) {
    final direction = _textDirectionFor('${article.title} ${article.summary}');
    final align = _textAlignFor('${article.title} ${article.summary}');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.sizeOf(context).height * 0.72,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.background,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: _DetailHeroImage(article: article),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _MetaChip(
                        icon: Icons.article_rounded,
                        label: article.source,
                      ),
                      if (rank != null) ...[
                        _MetaChip(
                          icon: Icons.tag_rounded,
                          label: '#$rank',
                          muted: true,
                        ),
                      ],
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: _formatDate(article.publishedAt),
                        muted: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    article.title,
                    textDirection: direction,
                    textAlign: align,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      height: 1.18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Text(
                      article.summary,
                      textDirection: direction,
                      textAlign: align,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 15.5,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.sports_soccer_rounded,
                        size: 16,
                        color: AppColors.primary.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.t('newsDetailFooter'),
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
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

class _DetailHeroImage extends StatelessWidget {
  final SportsNewsArticle article;

  const _DetailHeroImage({required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const _FullFormatAssetImage();
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            opacity: const AlwaysStoppedAnimation(0.20),
            errorBuilder: (context, error, stackTrace) {
              return const _FullFormatAssetImage();
            },
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 58, 0, 24),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const _FullFormatAssetImage();
                  },
                ),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x88000000),
                  Colors.transparent,
                  Color(0xCC071510),
                ],
                stops: [0.0, 0.62, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullFormatAssetImage extends StatelessWidget {
  const _FullFormatAssetImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/futivo_news_hero.png',
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool muted;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: muted
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: muted
              ? Colors.white.withValues(alpha: 0.10)
              : AppColors.primary.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: muted ? AppColors.textMuted : AppColors.primaryGlow,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: muted ? AppColors.textMuted : AppColors.primaryGlow,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
