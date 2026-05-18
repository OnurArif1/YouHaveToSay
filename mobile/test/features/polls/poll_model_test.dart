import 'package:flutter_test/flutter_test.dart';
import 'package:you_have_to_say/features/polls/data/models/poll_dto.dart';

void main() {
  test('PollDto maps json to domain with locale text', () {
    final dto = PollDto.fromJson({
      'id': '11111111-1111-1111-1111-111111111111',
      'questionTr': 'Merhaba?',
      'questionEn': 'Hello?',
      'options': [
        {
          'id': '22222222-2222-2222-2222-222222222222',
          'optionTextTr': 'Evet',
          'optionTextEn': 'Yes',
        },
      ],
    });

    final poll = dto.toDomain();

    expect(poll.questionForLocale('tr'), 'Merhaba?');
    expect(poll.questionForLocale('en'), 'Hello?');
    expect(poll.options.first.textForLocale('tr'), 'Evet');
    expect(poll.options.first.textForLocale('en'), 'Yes');
  });
}
