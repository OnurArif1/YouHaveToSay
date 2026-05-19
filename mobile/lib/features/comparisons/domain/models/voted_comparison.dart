import 'package:equatable/equatable.dart';

import 'comparison.dart';
import 'comparison_vote_result.dart';

class VotedComparison extends Equatable {
  const VotedComparison({
    required this.comparison,
    required this.selectedOptionId,
    required this.votedAt,
    required this.voteResult,
  });

  final Comparison comparison;
  final String selectedOptionId;
  final DateTime votedAt;
  final ComparisonVoteResult voteResult;

  @override
  List<Object?> get props => [comparison, selectedOptionId, votedAt, voteResult];
}
