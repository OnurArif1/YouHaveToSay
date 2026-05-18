import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/polls_repository_impl.dart';
import '../../domain/models/poll.dart';
import '../../domain/polls_repository.dart';

part 'poll_event.dart';
part 'poll_state.dart';

class PollBloc extends Bloc<PollEvent, PollState> {
  PollBloc({required PollsRepository pollsRepository})
      : _pollsRepository = pollsRepository,
        super(const PollState()) {
    on<PollLoadNextRequested>(_onLoadNext);
    on<PollVoteSubmitted>(_onVote);
  }

  final PollsRepository _pollsRepository;

  Future<void> _onLoadNext(
    PollLoadNextRequested event,
    Emitter<PollState> emit,
  ) async {
    emit(state.copyWith(
      status: PollStatus.loading,
      clearError: true,
      showSuccessAnimation: false,
    ));

    try {
      final poll = await _pollsRepository.getNextPoll();
      emit(state.copyWith(
        status: PollStatus.loaded,
        poll: poll,
        slideKey: state.slideKey + 1,
      ));
    } on NoMorePollsException {
      emit(state.copyWith(status: PollStatus.noMorePolls, poll: null));
    } catch (_) {
      emit(state.copyWith(
        status: PollStatus.error,
        errorMessage: 'poll_load_error',
      ));
    }
  }

  Future<void> _onVote(
    PollVoteSubmitted event,
    Emitter<PollState> emit,
  ) async {
    final poll = state.poll;
    if (poll == null) return;

    emit(state.copyWith(
      status: PollStatus.voting,
      selectedOptionId: event.optionId,
      clearError: true,
    ));

    try {
      await _pollsRepository.vote(
        pollId: poll.id,
        optionId: event.optionId,
      );

      emit(state.copyWith(
        status: PollStatus.voteSuccess,
        showSuccessAnimation: true,
      ));

      await Future<void>.delayed(const Duration(milliseconds: 700));
      add(const PollLoadNextRequested());
    } catch (_) {
      emit(state.copyWith(
        status: PollStatus.loaded,
        errorMessage: 'vote_error',
        showSuccessAnimation: false,
      ));
    }
  }
}
