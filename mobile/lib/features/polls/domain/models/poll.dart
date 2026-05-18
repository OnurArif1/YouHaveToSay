import 'package:equatable/equatable.dart';

class Poll extends Equatable {
  const Poll({
    required this.id,
    required this.questionTr,
    required this.questionEn,
    required this.options,
  });

  final String id;
  final String questionTr;
  final String questionEn;
  final List<PollOption> options;

  String questionForLocale(String languageCode) =>
      languageCode == 'tr' ? questionTr : questionEn;

  @override
  List<Object?> get props => [id, questionTr, questionEn, options];
}

class PollOption extends Equatable {
  const PollOption({
    required this.id,
    required this.optionTextTr,
    required this.optionTextEn,
  });

  final String id;
  final String optionTextTr;
  final String optionTextEn;

  String textForLocale(String languageCode) =>
      languageCode == 'tr' ? optionTextTr : optionTextEn;

  @override
  List<Object?> get props => [id, optionTextTr, optionTextEn];
}
