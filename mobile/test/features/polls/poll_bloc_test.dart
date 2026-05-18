import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:you_have_to_say/features/polls/data/polls_repository_impl.dart';
import 'package:you_have_to_say/features/polls/domain/models/poll.dart';
import 'package:you_have_to_say/features/polls/domain/polls_repository.dart';
import 'package:you_have_to_say/features/polls/presentation/bloc/poll_bloc.dart';

class MockPollsRepository extends Mock implements PollsRepository {}

void main() {
  late MockPollsRepository repository;

  const poll = Poll(
    id: 'poll-1',
    questionTr: 'Soru?',
    questionEn: 'Question?',
    options: [
      PollOption(id: 'opt-1', optionTextTr: 'A', optionTextEn: 'A'),
      PollOption(id: 'opt-2', optionTextTr: 'B', optionTextEn: 'B'),
    ],
  );

  setUp(() {
    repository = MockPollsRepository();
  });

  blocTest<PollBloc, PollState>(
    'loads next poll',
    build: () => PollBloc(pollsRepository: repository),
    setUp: () {
      when(() => repository.getNextPoll()).thenAnswer((_) async => poll);
    },
    act: (bloc) => bloc.add(const PollLoadNextRequested()),
    expect: () => [
      isA<PollState>().having((s) => s.status, 'status', PollStatus.loading),
      isA<PollState>()
          .having((s) => s.status, 'status', PollStatus.loaded)
          .having((s) => s.poll?.id, 'pollId', 'poll-1'),
    ],
  );

  blocTest<PollBloc, PollState>(
    'emits noMorePolls when repository throws',
    build: () => PollBloc(pollsRepository: repository),
    setUp: () {
      when(() => repository.getNextPoll()).thenThrow(const NoMorePollsException());
    },
    act: (bloc) => bloc.add(const PollLoadNextRequested()),
    expect: () => [
      isA<PollState>().having((s) => s.status, 'status', PollStatus.loading),
      isA<PollState>().having((s) => s.status, 'status', PollStatus.noMorePolls),
    ],
  );
}
