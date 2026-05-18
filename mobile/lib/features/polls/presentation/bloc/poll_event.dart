part of 'poll_bloc.dart';

sealed class PollEvent extends Equatable {
  const PollEvent();

  @override
  List<Object?> get props => [];
}

final class PollLoadNextRequested extends PollEvent {
  const PollLoadNextRequested();
}

final class PollVoteSubmitted extends PollEvent {
  const PollVoteSubmitted({required this.optionId});

  final String optionId;

  @override
  List<Object?> get props => [optionId];
}
