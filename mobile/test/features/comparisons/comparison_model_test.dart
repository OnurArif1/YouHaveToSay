import 'package:flutter_test/flutter_test.dart';
import 'package:you_have_to_say/features/comparisons/data/models/comparison_dto.dart';

void main() {
  group('ComparisonDto', () {
    test('parses feed response', () {
      final dto = ComparisonFeedResponseDto.fromJson({
        'items': [
          {
            'id': 'cmp-1',
            'titleTr': 'Hangisi?',
            'titleEn': 'Which one?',
            'leftOption': {
              'id': 'left-1',
              'textTr': 'A',
              'textEn': 'A',
              'imageUrl': null,
            },
            'rightOption': {
              'id': 'right-1',
              'textTr': 'B',
              'textEn': 'B',
              'imageUrl': null,
            },
            'category': 'colors',
            'hasVoted': false,
          }
        ],
        'hasMore': true,
      });

      final domain = dto.toDomain();
      expect(domain.items.length, 1);
      expect(domain.hasMore, isTrue);
      expect(domain.items.first.leftOption.textTr, 'A');
    });

    test('parses vote result', () {
      final dto = ComparisonVoteResultDto.fromJson({
        'comparisonId': 'cmp-1',
        'selectedOptionId': 'left-1',
        'totalVotes': 10,
        'leftOption': {'id': 'left-1', 'voteCount': 6, 'percentage': 60},
        'rightOption': {'id': 'right-1', 'voteCount': 4, 'percentage': 40},
      });

      final domain = dto.toDomain();
      expect(domain.totalVotes, 10);
      expect(domain.leftOption.percentage, 60);
    });
  });
}
