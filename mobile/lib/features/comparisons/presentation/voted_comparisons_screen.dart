import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/comparison_repository.dart';
import '../domain/models/voted_comparison.dart';
import 'widgets/feed_background.dart';
import 'widgets/voted_comparison_tile.dart';

class VotedComparisonsScreen extends StatefulWidget {
  const VotedComparisonsScreen({super.key});

  @override
  State<VotedComparisonsScreen> createState() => _VotedComparisonsScreenState();
}

class _VotedComparisonsScreenState extends State<VotedComparisonsScreen> {
  Future<List<VotedComparison>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = getIt<ComparisonRepository>().getVotedHistory();
    });
  }

  String _t(BuildContext context, String key) {
    final value = context.tr(key);
    if (value != key) return value;
    // Hot reload sonrası yeni anahtarlar bazen yüklenmez — TR yedek metinler
    const fallbacks = {
      'voted_history': 'Oyladıklarım',
      'voted_history_empty': 'Henüz oy verdiğin bir karşılaştırma yok.',
      'voted_history_error': 'Geçmiş yüklenemedi.',
      'retry': 'Tekrar Dene',
    };
    if (context.locale.languageCode == 'tr' && fallbacks.containsKey(key)) {
      return fallbacks[key]!;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_t(context, 'voted_history')),
        ),
        body: FeedBackground(
          child: FutureBuilder<List<VotedComparison>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _t(context, 'voted_history_error'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.subtitle),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: Text(_t(context, 'retry')),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      _t(context, 'voted_history_empty'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return VotedComparisonTile(
                    item: items[index],
                    locale: locale,
                  );
                },
              );
            },
        ),
      ),
    );
  }
}
