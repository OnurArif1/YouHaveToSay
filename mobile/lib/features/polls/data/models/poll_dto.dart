import '../../domain/models/poll.dart';

class PollDto {
  const PollDto({
    required this.id,
    required this.questionTr,
    required this.questionEn,
    required this.options,
  });

  factory PollDto.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? [];
    return PollDto(
      id: json['id'].toString(),
      questionTr: json['questionTr'] as String,
      questionEn: json['questionEn'] as String,
      options: optionsJson
          .map((e) => PollOptionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String questionTr;
  final String questionEn;
  final List<PollOptionDto> options;

  Poll toDomain() => Poll(
        id: id,
        questionTr: questionTr,
        questionEn: questionEn,
        options: options.map((o) => o.toDomain()).toList(),
      );
}

class PollOptionDto {
  const PollOptionDto({
    required this.id,
    required this.optionTextTr,
    required this.optionTextEn,
  });

  factory PollOptionDto.fromJson(Map<String, dynamic> json) {
    return PollOptionDto(
      id: json['id'].toString(),
      optionTextTr: json['optionTextTr'] as String,
      optionTextEn: json['optionTextEn'] as String,
    );
  }

  final String id;
  final String optionTextTr;
  final String optionTextEn;

  PollOption toDomain() => PollOption(
        id: id,
        optionTextTr: optionTextTr,
        optionTextEn: optionTextEn,
      );
}
