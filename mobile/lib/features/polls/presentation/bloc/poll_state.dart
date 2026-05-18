part of 'poll_bloc.dart';

enum PollStatus {
  initial,
  loading,
  loaded,
  voting,
  voteSuccess,
  noMorePolls,
  error,
}

final class PollState extends Equatable {
  const PollState({
    this.status = PollStatus.initial,
    this.poll,
    this.selectedOptionId,
    this.errorMessage,
    this.showSuccessAnimation = false,
    this.slideKey = 0,
  });

  final PollStatus status;
  final Poll? poll;
  final String? selectedOptionId;
  final String? errorMessage;
  final bool showSuccessAnimation;
  final int slideKey;

  PollState copyWith({
    PollStatus? status,
    Poll? poll,
    String? selectedOptionId,
    String? errorMessage,
    bool? showSuccessAnimation,
    int? slideKey,
    bool clearError = false,
  }) {
    return PollState(
      status: status ?? this.status,
      poll: poll ?? this.poll,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      showSuccessAnimation: showSuccessAnimation ?? this.showSuccessAnimation,
      slideKey: slideKey ?? this.slideKey,
    );
  }

  @override
  List<Object?> get props => [
        status,
        poll,
        selectedOptionId,
        errorMessage,
        showSuccessAnimation,
        slideKey,
      ];
}
