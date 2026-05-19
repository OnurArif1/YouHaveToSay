import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/comparison_repository_impl.dart';
import '../../domain/comparison_repository.dart';
import '../../domain/models/comparison.dart';
import '../../domain/models/comparison_vote_result.dart';

part 'comparison_feed_event.dart';
part 'comparison_feed_state.dart';

class ComparisonFeedBloc extends Bloc<ComparisonFeedEvent, ComparisonFeedState> {
  ComparisonFeedBloc({required ComparisonRepository comparisonRepository})
      : _repository = comparisonRepository,
        super(const ComparisonFeedState()) {
    on<ComparisonFeedStarted>(_onStarted);
    on<ComparisonFeedNextPageRequested>(_onNextPage);
    on<ComparisonVoteSubmitted>(_onVote);
    on<ComparisonCardDismissed>(_onCardDismissed);
    on<ComparisonFeedRefreshRequested>(_onRefresh);
  }

  static const int _feedLimit = 10;
  static const int _preloadThreshold = 3;

  final ComparisonRepository _repository;

  Future<void> _onStarted(
    ComparisonFeedStarted event,
    Emitter<ComparisonFeedState> emit,
  ) async {
    emit(state.copyWith(
      status: ComparisonFeedStatus.loading,
      queue: const [],
      currentIndex: 0,
      voteResultsByComparisonId: const {},
      clearError: true,
      clearSelectedOption: true,
    ));

    await _loadMore(emit, isInitial: true);
  }

  Future<void> _onNextPage(
    ComparisonFeedNextPageRequested event,
    Emitter<ComparisonFeedState> emit,
  ) async {
    if (!state.hasMoreFromBackend && state.isLoadingMore) return;
    await _loadMore(emit);
  }

  Future<void> _onRefresh(
    ComparisonFeedRefreshRequested event,
    Emitter<ComparisonFeedState> emit,
  ) async {
    add(const ComparisonFeedStarted());
  }

  Future<void> _onVote(
    ComparisonVoteSubmitted event,
    Emitter<ComparisonFeedState> emit,
  ) async {
    final current = state.currentComparison;
    if (current == null) return;
    if (state.status == ComparisonFeedStatus.voting) return;
    if (state.voteResultsByComparisonId.containsKey(current.id)) return;

    emit(state.copyWith(
      status: ComparisonFeedStatus.voting,
      selectedOptionId: event.optionId,
      clearError: true,
    ));

    try {
      final result = await _repository.voteComparison(
        comparisonId: current.id,
        selectedOptionId: event.optionId,
      );

      final updatedResults = Map<String, ComparisonVoteResult>.from(
        state.voteResultsByComparisonId,
      )..[current.id] = result;

      emit(state.copyWith(
        status: ComparisonFeedStatus.voteSuccess,
        voteResultsByComparisonId: updatedResults,
      ));

      await _maybePreload(emit);
    } on AlreadyVotedException {
      emit(state.copyWith(
        status: ComparisonFeedStatus.loaded,
        errorMessage: 'already_voted',
        clearSelectedOption: true,
      ));
      add(const ComparisonCardDismissed());
    } catch (_) {
      emit(state.copyWith(
        status: ComparisonFeedStatus.loaded,
        errorMessage: 'vote_error',
        clearSelectedOption: true,
      ));
    }
  }

  void _onCardDismissed(
    ComparisonCardDismissed event,
    Emitter<ComparisonFeedState> emit,
  ) {
    if (state.currentComparison == null) return;

    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.queue.length) {
      if (state.hasMoreFromBackend) {
        emit(state.copyWith(
          status: ComparisonFeedStatus.loading,
          currentIndex: nextIndex,
          clearSelectedOption: true,
        ));
        add(const ComparisonFeedNextPageRequested());
      } else {
        emit(state.copyWith(
          status: ComparisonFeedStatus.empty,
          currentIndex: nextIndex,
          clearSelectedOption: true,
        ));
      }
      return;
    }

    emit(state.copyWith(
      status: ComparisonFeedStatus.loaded,
      currentIndex: nextIndex,
      clearSelectedOption: true,
    ));

    _maybePreload(emit);
  }

  Future<void> _loadMore(
    Emitter<ComparisonFeedState> emit, {
    bool isInitial = false,
  }) async {
    if (state.isLoadingMore) return;
    if (!state.hasMoreFromBackend && !isInitial) {
      if (state.queue.isEmpty || state.currentIndex >= state.queue.length) {
        emit(state.copyWith(status: ComparisonFeedStatus.empty));
      }
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final response = await _repository.getComparisonFeed(limit: _feedLimit);
      final existingIds = state.queue.map((c) => c.id).toSet();
      final newItems =
          response.items.where((c) => !existingIds.contains(c.id)).toList();

      final updatedQueue = [...state.queue, ...newItems];

      if (updatedQueue.isEmpty) {
        emit(state.copyWith(
          status: ComparisonFeedStatus.empty,
          queue: updatedQueue,
          hasMoreFromBackend: false,
          isLoadingMore: false,
        ));
        return;
      }

      final wasPastEnd = state.currentIndex >= state.queue.length;
      final newIndex = wasPastEnd && newItems.isNotEmpty
          ? state.queue.length
          : state.currentIndex;

      emit(state.copyWith(
        status: ComparisonFeedStatus.loaded,
        queue: updatedQueue,
        currentIndex: newIndex.clamp(0, updatedQueue.length - 1),
        hasMoreFromBackend: response.hasMore,
        isLoadingMore: false,
      ));

      await _maybePreload(emit);
    } catch (_) {
      emit(state.copyWith(
        status: isInitial
            ? ComparisonFeedStatus.failure
            : ComparisonFeedStatus.loaded,
        isLoadingMore: false,
        errorMessage: 'feed_load_error',
      ));
    }
  }

  Future<void> _maybePreload(Emitter<ComparisonFeedState> emit) async {
    if (!state.hasMoreFromBackend || state.isLoadingMore) return;
    if (state.remainingCards > _preloadThreshold) return;
    await _loadMore(emit);
  }
}
