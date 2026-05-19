import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:you_have_to_say/features/comparisons/data/comparison_repository_impl.dart';
import 'package:you_have_to_say/features/comparisons/domain/comparison_repository.dart';
import 'package:you_have_to_say/features/comparisons/domain/models/comparison.dart';
import 'package:you_have_to_say/features/comparisons/domain/models/comparison_feed_response.dart';
import 'package:you_have_to_say/features/comparisons/domain/models/comparison_option.dart';
import 'package:you_have_to_say/features/comparisons/domain/models/comparison_vote_result.dart';
import 'package:you_have_to_say/features/comparisons/presentation/bloc/comparison_feed_bloc.dart';

class MockComparisonRepository extends Mock implements ComparisonRepository {}

void main() {
  late MockComparisonRepository repository;

  const comparison = Comparison(
    id: 'cmp-1',
    titleTr: 'Test',
    titleEn: 'Test',
    leftOption: ComparisonOption(id: 'l', textTr: 'L', textEn: 'L'),
    rightOption: ComparisonOption(id: 'r', textTr: 'R', textEn: 'R'),
    category: 'colors',
  );

  setUp(() {
    repository = MockComparisonRepository();
  });

  blocTest<ComparisonFeedBloc, ComparisonFeedState>(
    'loads feed on start',
    build: () => ComparisonFeedBloc(comparisonRepository: repository),
    setUp: () {
      when(() => repository.getComparisonFeed(limit: any(named: 'limit')))
          .thenAnswer(
        (_) async => const ComparisonFeedResponse(
          items: [comparison],
          hasMore: false,
        ),
      );
    },
    act: (bloc) => bloc.add(const ComparisonFeedStarted()),
    skip: 1,
    expect: () => [
      isA<ComparisonFeedState>().having(
        (s) => s.status,
        'status',
        ComparisonFeedStatus.loading,
      ),
      isA<ComparisonFeedState>().having(
        (s) => s.status,
        'status',
        ComparisonFeedStatus.loaded,
      ),
    ],
  );

  blocTest<ComparisonFeedBloc, ComparisonFeedState>(
    'vote success stores result',
    build: () => ComparisonFeedBloc(comparisonRepository: repository),
    seed: () => const ComparisonFeedState(
      status: ComparisonFeedStatus.loaded,
      queue: [comparison],
    ),
    setUp: () {
      when(() => repository.getComparisonFeed(limit: any(named: 'limit')))
          .thenAnswer(
        (_) async => const ComparisonFeedResponse(items: [], hasMore: false),
      );
      when(
        () => repository.voteComparison(
          comparisonId: any(named: 'comparisonId'),
          selectedOptionId: any(named: 'selectedOptionId'),
        ),
      ).thenAnswer(
        (_) async => const ComparisonVoteResult(
          comparisonId: 'cmp-1',
          selectedOptionId: 'l',
          totalVotes: 1,
          leftOption: ComparisonVoteOptionResult(id: 'l', voteCount: 1, percentage: 100),
          rightOption: ComparisonVoteOptionResult(id: 'r', voteCount: 0, percentage: 0),
        ),
      );
    },
    act: (bloc) => bloc.add(const ComparisonVoteSubmitted(optionId: 'l')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.voteResultsByComparisonId['cmp-1'], isNotNull);
      verify(
        () => repository.voteComparison(
          comparisonId: 'cmp-1',
          selectedOptionId: 'l',
        ),
      ).called(1);
    },
  );
}
