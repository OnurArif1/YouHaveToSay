import 'models/comparison_feed_response.dart';
import 'models/comparison_vote_result.dart';
import 'models/voted_comparison.dart';

abstract class ComparisonRepository {
  Future<ComparisonFeedResponse> getComparisonFeed({int limit = 10});

  Future<ComparisonVoteResult> voteComparison({
    required String comparisonId,
    required String selectedOptionId,
  });

  Future<List<VotedComparison>> getVotedHistory({int limit = 50});
}
