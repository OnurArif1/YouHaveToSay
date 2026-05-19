import 'package:equatable/equatable.dart';

import 'comparison_option.dart';

class Comparison extends Equatable {
  const Comparison({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.leftOption,
    required this.rightOption,
    required this.category,
    this.hasVoted = false,
  });

  final String id;
  final String titleTr;
  final String titleEn;
  final ComparisonOption leftOption;
  final ComparisonOption rightOption;
  final String category;
  final bool hasVoted;

  String titleForLocale(String languageCode) =>
      languageCode == 'tr' ? titleTr : titleEn;

  @override
  List<Object?> get props =>
      [id, titleTr, titleEn, leftOption, rightOption, category, hasVoted];
}
