part of 'comparison_feed_bloc.dart';

sealed class ComparisonFeedEvent extends Equatable {
  const ComparisonFeedEvent();

  @override
  List<Object?> get props => [];
}

final class ComparisonFeedStarted extends ComparisonFeedEvent {
  const ComparisonFeedStarted();
}

final class ComparisonFeedNextPageRequested extends ComparisonFeedEvent {
  const ComparisonFeedNextPageRequested();
}

final class ComparisonVoteSubmitted extends ComparisonFeedEvent {
  const ComparisonVoteSubmitted({required this.optionId});

  final String optionId;

  @override
  List<Object?> get props => [optionId];
}

final class ComparisonCardDismissed extends ComparisonFeedEvent {
  const ComparisonCardDismissed();
}

final class ComparisonFeedRefreshRequested extends ComparisonFeedEvent {
  const ComparisonFeedRefreshRequested();
}
