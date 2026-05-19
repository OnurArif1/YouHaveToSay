import 'package:equatable/equatable.dart';

class ComparisonOption extends Equatable {
  const ComparisonOption({
    required this.id,
    required this.textTr,
    required this.textEn,
    this.imageUrl,
  });

  final String id;
  final String textTr;
  final String textEn;
  final String? imageUrl;

  String textForLocale(String languageCode) =>
      languageCode == 'tr' ? textTr : textEn;

  @override
  List<Object?> get props => [id, textTr, textEn, imageUrl];
}
