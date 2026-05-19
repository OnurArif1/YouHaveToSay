part of 'comparison_feed_bloc.dart';

enum ComparisonFeedStatus {
  initial,
  loading,
  loaded,
  voting,
  voteSuccess,
  empty,
  failure,
}

class ComparisonFeedState extends Equatable {
  const ComparisonFeedState({
    this.status = ComparisonFeedStatus.initial,
    this.queue = const [],
    this.currentIndex = 0,
    this.voteResultsByComparisonId = const {},
    this.selectedOptionId,
    this.hasMoreFromBackend = true,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final ComparisonFeedStatus status;
  final List<Comparison> queue;
  final int currentIndex;
  final Map<String, ComparisonVoteResult> voteResultsByComparisonId;
  final String? selectedOptionId;
  final bool hasMoreFromBackend;
  final bool isLoadingMore;
  final String? errorMessage;

  Comparison? get currentComparison =>
      currentIndex >= 0 && currentIndex < queue.length ? queue[currentIndex] : null;

  ComparisonVoteResult? get currentVoteResult {
    final current = currentComparison;
    if (current == null) return null;
    return voteResultsByComparisonId[current.id];
  }

  bool get canSwipeToNext =>
      status == ComparisonFeedStatus.voteSuccess && currentVoteResult != null;

  int get remainingCards => queue.length - currentIndex;

  ComparisonFeedState copyWith({
    ComparisonFeedStatus? status,
    List<Comparison>? queue,
    int? currentIndex,
    Map<String, ComparisonVoteResult>? voteResultsByComparisonId,
    String? selectedOptionId,
    bool? hasMoreFromBackend,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedOption = false,
  }) {
    return ComparisonFeedState(
      status: status ?? this.status,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      voteResultsByComparisonId:
          voteResultsByComparisonId ?? this.voteResultsByComparisonId,
      selectedOptionId:
          clearSelectedOption ? null : (selectedOptionId ?? this.selectedOptionId),
      hasMoreFromBackend: hasMoreFromBackend ?? this.hasMoreFromBackend,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        queue,
        currentIndex,
        voteResultsByComparisonId,
        selectedOptionId,
        hasMoreFromBackend,
        isLoadingMore,
        errorMessage,
      ];
}
