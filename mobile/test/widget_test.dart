import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:you_have_to_say/features/polls/domain/models/poll.dart';
import 'package:you_have_to_say/features/polls/presentation/widgets/poll_card.dart';

void main() {
  testWidgets('PollCard shows localized question and options', (tester) async {
    const poll = Poll(
      id: '1',
      questionTr: 'Kahve mi çay mı?',
      questionEn: 'Coffee or tea?',
      options: [
        PollOption(id: 'a', optionTextTr: 'Kahve', optionTextEn: 'Coffee'),
        PollOption(id: 'b', optionTextTr: 'Çay', optionTextEn: 'Tea'),
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MaterialApp(
          home: Scaffold(body: child),
        ),
        child: const PollCard(
          poll: poll,
          locale: 'tr',
          onOptionTap: _noop,
        ),
      ),
    );

    expect(find.text('Kahve mi çay mı?'), findsOneWidget);
    expect(find.text('Kahve'), findsOneWidget);
    expect(find.text('Çay'), findsOneWidget);
  });
}

void _noop(String _) {}
