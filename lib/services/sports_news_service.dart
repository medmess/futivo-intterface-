import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/news_ad.dart';
import '../models/sports_news_article.dart';

class SportsNewsService {
  final http.Client _client;

  SportsNewsService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<SportsNewsArticle>> fetchLatest() async {
    final baseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (baseUrl == null || baseUrl.trim().isEmpty) return const [];

    try {
      final cleanedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
      final uri = Uri.parse('$cleanedBaseUrl/api/news/latest?limit=30');
      final response = await _client.get(uri);
      if (response.statusCode != 200) return const [];

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => item as Map<String, dynamic>)
          .map((item) {
            final caption = _cleanCaption(item['caption'] as String? ?? '');
            final title = _titleFromCaption(caption);
            final summary = _summaryFromCaption(caption);
            return SportsNewsArticle(
              title: title,
              source: item['source'] as String? ?? 'Offside',
              summary: summary.isEmpty
                  ? 'Telegram football news update.'
                  : summary,
              imageUrl: item['imageUrl'] as String?,
              publishedAt:
                  DateTime.tryParse(item['publishedAt'] as String? ?? '') ??
                  DateTime.now(),
            );
          })
          .where(_isSportsRelated)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<NewsAd>> fetchNewsAds() async {
    final baseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (baseUrl == null || baseUrl.trim().isEmpty) return const [];

    try {
      final cleanedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
      final uri = Uri.parse('$cleanedBaseUrl/api/ads/news');
      final response = await _client.get(uri);
      if (response.statusCode != 200) return const [];

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => item as Map<String, dynamic>)
          .map(
            (item) => NewsAd(
              id: item['id'] as String? ?? '',
              title: item['title'] as String? ?? '',
              subtitle: item['subtitle'] as String?,
              imageUrl: item['imageUrl'] as String? ?? '',
              targetUrl: item['targetUrl'] as String?,
              isActive: item['isActive'] as bool? ?? true,
            ),
          )
          .where((ad) => ad.isActive && ad.imageUrl.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  String _cleanCaption(String caption) {
    final cleaned = caption
        .replaceAll(RegExp(r'[\u200e\u200f]'), '')
        .replaceAll(RegExp(r'\u0640+'), '')
        .replaceAll(RegExp(r'[*_`~]+'), '')
        .replaceAll(
          RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true),
          '',
        )
        .replaceAll(RegExp(r'[\u2022\u25cf\u25aa\u25ab\u25e6]+'), '')
        .replaceAll(RegExp(r'\s*[|]{2,}\s*'), ' ')
        .replaceAllMapped(
          RegExp(r'([!\u061f?]){2,}'),
          (match) => match.group(1)!,
        )
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    final seen = <String>{};
    final lines = cleaned
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) {
          final normalized = _normalizeForMatching(line)
              .replaceAll(RegExp(r'[^\u0600-\u06FFa-z0-9 ]'), '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          if (normalized.isEmpty) return false;
          if (seen.contains(normalized)) return false;
          seen.add(normalized);
          return true;
        })
        .toList();

    return lines.join('\n').trim();
  }

  bool _isSportsRelated(SportsNewsArticle article) {
    final source = article.source.toLowerCase();
    if (source.contains('admin') || source.contains('futivo')) return true;

    final text = _normalizeForMatching('${article.title} ${article.summary}');
    const keywords = [
      'football',
      'soccer',
      'world cup',
      'fifa',
      'match',
      'goal',
      'player',
      'team',
      'club',
      'league',
      'transfer',
      '\u0643\u0623\u0633 \u0627\u0644\u0639\u0627\u0644\u0645',
      '\u0645\u0648\u0646\u062f\u064a\u0627\u0644',
      '\u0627\u0644\u0641\u064a\u0641\u0627',
      '\u0641\u064a\u0641\u0627',
      '\u0643\u0631\u0629',
      '\u0627\u0644\u0642\u062f\u0645',
      '\u0645\u0628\u0627\u0631',
      '\u0645\u0628\u0627\u0631\u0627\u0629',
      '\u0645\u0628\u0627\u0631\u064a\u0627\u062a',
      '\u0645\u0646\u062a\u062e\u0628',
      '\u0644\u0627\u0639\u0628',
      '\u0645\u062f\u0631\u0628',
      '\u0646\u0627\u062f\u064a',
      '\u0627\u0644\u062f\u0648\u0631\u064a',
      '\u0647\u062f\u0641',
      '\u0623\u0647\u062f\u0627\u0641',
      'transfert',
      'joueur',
      'coupe du monde',
      '\u00e9quipe',
      'equipe',
    ];
    return keywords.any(text.contains);
  }

  String _normalizeForMatching(String value) {
    return value.replaceAll(RegExp(r'[\u064b-\u065f\u0670]'), '').toLowerCase();
  }

  String _titleFromCaption(String caption) {
    final clean = caption.trim();
    if (clean.isEmpty) return 'Football news update';
    final firstLine = clean
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => clean);
    if (firstLine.length <= 90) return firstLine;
    return '${firstLine.substring(0, 87)}...';
  }

  String _summaryFromCaption(String caption) {
    final lines = caption
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.length <= 1) return caption.trim();
    return lines.skip(1).join('\n').trim();
  }
}
