import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/analytics/comparison_analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../presentation/bloc/comparison_feed_bloc.dart';
import 'voted_comparisons_screen.dart';
import 'widgets/comparison_card.dart';
import 'widgets/feed_background.dart';

class ComparisonFeedScreen extends StatefulWidget {
  const ComparisonFeedScreen({super.key});

  @override
  State<ComparisonFeedScreen> createState() => _ComparisonFeedScreenState();
}

class _ComparisonFeedScreenState extends State<ComparisonFeedScreen> {
  @override
  void initState() {
    super.initState();
    ComparisonAnalytics.comparisonFeedOpened();
    context.read<ComparisonFeedBloc>().add(const ComparisonFeedStarted());
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text('app_name'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: context.tr('voted_history') == 'voted_history'
                ? 'Oyladıklarım'
                : context.tr('voted_history'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const VotedComparisonsScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (code) => context.setLocale(Locale(code)),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'tr', child: Text('turkish'.tr())),
              PopupMenuItem(value: 'en', child: Text('english'.tr())),
            ],
            icon: const Icon(Icons.language),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'sign_out'.tr(),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
        ],
      ),
      body: FeedBackground(
        child: BlocConsumer<ComparisonFeedBloc, ComparisonFeedState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!.tr())),
            );
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case ComparisonFeedStatus.initial:
            case ComparisonFeedStatus.loading when state.currentComparison == null:
              return _LoadingView(message: 'loading_comparisons'.tr());
            case ComparisonFeedStatus.failure:
              return _ErrorView(
                message: state.errorMessage?.tr() ?? 'feed_load_error'.tr(),
                onRetry: () => context
                    .read<ComparisonFeedBloc>()
                    .add(const ComparisonFeedRefreshRequested()),
              );
            case ComparisonFeedStatus.empty:
              ComparisonAnalytics.comparisonFeedEmpty();
              return _EmptyView();
            default:
              final comparison = state.currentComparison;
              if (comparison == null) {
                if (state.isLoadingMore) {
                  return _LoadingView(message: 'loading_comparisons'.tr());
                }
                return _EmptyView();
              }

              ComparisonAnalytics.comparisonCardSeen(
                comparisonId: comparison.id,
                category: comparison.category,
              );

              return GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < -300 &&
                      state.canSwipeToNext) {
                    ComparisonAnalytics.comparisonCardSwiped(
                      comparisonId: comparison.id,
                    );
                    context
                        .read<ComparisonFeedBloc>()
                        .add(const ComparisonCardDismissed());
                  }
                },
                child: ComparisonCard(
                  key: ValueKey(comparison.id),
                  comparison: comparison,
                  locale: locale,
                  isVoting: state.status == ComparisonFeedStatus.voting,
                  selectedOptionId: state.selectedOptionId,
                  voteResult: state.currentVoteResult,
                  onOptionTap: (optionId) {
                    if (state.voteResultsByComparisonId.containsKey(comparison.id)) {
                      return;
                    }
                    ComparisonAnalytics.comparisonVoteSubmitted(
                      comparisonId: comparison.id,
                      optionId: optionId,
                    );
                    context.read<ComparisonFeedBloc>().add(
                          ComparisonVoteSubmitted(optionId: optionId),
                        );
                  },
                  onResultSeen: () {
                    ComparisonAnalytics.comparisonResultSeen(
                      comparisonId: comparison.id,
                    );
                  },
                ),
              );
          }
        },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 72, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(height: 20),
            Text(
              'no_more_comparisons_title'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'no_more_comparisons_body'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
