import 'package:flutter/foundation.dart';

/// Lightweight analytics — no PII, no tokens.
class ComparisonAnalytics {
  const ComparisonAnalytics._();

  static void comparisonFeedOpened() =>
      _log('comparison_feed_opened');

  static void comparisonCardSeen({required String comparisonId, String? category}) =>
      _log('comparison_card_seen', {'comparisonId': comparisonId, if (category != null) 'category': category});

  static void comparisonVoteSubmitted({required String comparisonId, required String optionId}) =>
      _log('comparison_vote_submitted', {'comparisonId': comparisonId, 'optionId': optionId});

  static void comparisonVoteSuccess({required String comparisonId}) =>
      _log('comparison_vote_success', {'comparisonId': comparisonId});

  static void comparisonVoteFailed({required String comparisonId, String? reason}) =>
      _log('comparison_vote_failed', {'comparisonId': comparisonId, if (reason != null) 'reason': reason});

  static void comparisonResultSeen({required String comparisonId}) =>
      _log('comparison_result_seen', {'comparisonId': comparisonId});

  static void comparisonCardSwiped({required String comparisonId}) =>
      _log('comparison_card_swiped', {'comparisonId': comparisonId});

  static void comparisonFeedEmpty() => _log('comparison_feed_empty');

  static void _log(String event, [Map<String, String>? params]) {
    if (kDebugMode) {
      debugPrint('[Analytics] $event ${params ?? ''}');
    }
  }
}
