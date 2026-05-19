import 'package:equatable/equatable.dart';

class ComparisonVoteResult extends Equatable {
  const ComparisonVoteResult({
    required this.comparisonId,
    required this.selectedOptionId,
    required this.totalVotes,
    required this.leftOption,
    required this.rightOption,
  });

  final String comparisonId;
  final String selectedOptionId;
  final int totalVotes;
  final ComparisonVoteOptionResult leftOption;
  final ComparisonVoteOptionResult rightOption;

  @override
  List<Object?> get props =>
      [comparisonId, selectedOptionId, totalVotes, leftOption, rightOption];
}

class ComparisonVoteOptionResult extends Equatable {
  const ComparisonVoteOptionResult({
    required this.id,
    required this.voteCount,
    required this.percentage,
  });

  final String id;
  final int voteCount;
  final double percentage;

  @override
  List<Object?> get props => [id, voteCount, percentage];
}
