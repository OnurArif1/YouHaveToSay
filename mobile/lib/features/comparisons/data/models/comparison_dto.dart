import '../../domain/models/comparison.dart';
import '../../domain/models/comparison_feed_response.dart';
import '../../domain/models/comparison_option.dart';
import '../../domain/models/comparison_vote_result.dart';
import '../../domain/models/voted_comparison.dart';

class ComparisonOptionDto {
  ComparisonOptionDto({
    required this.id,
    required this.textTr,
    required this.textEn,
    this.imageUrl,
  });

  final String id;
  final String textTr;
  final String textEn;
  final String? imageUrl;

  factory ComparisonOptionDto.fromJson(Map<String, dynamic> json) {
    return ComparisonOptionDto(
      id: json['id'].toString(),
      textTr: json['textTr'] as String,
      textEn: json['textEn'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  ComparisonOption toDomain() => ComparisonOption(
        id: id,
        textTr: textTr,
        textEn: textEn,
        imageUrl: imageUrl,
      );
}

class ComparisonDto {
  ComparisonDto({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.leftOption,
    required this.rightOption,
    required this.category,
    required this.hasVoted,
  });

  final String id;
  final String titleTr;
  final String titleEn;
  final ComparisonOptionDto leftOption;
  final ComparisonOptionDto rightOption;
  final String category;
  final bool hasVoted;

  factory ComparisonDto.fromJson(Map<String, dynamic> json) {
    return ComparisonDto(
      id: json['id'].toString(),
      titleTr: json['titleTr'] as String,
      titleEn: json['titleEn'] as String,
      leftOption: ComparisonOptionDto.fromJson(
        json['leftOption'] as Map<String, dynamic>,
      ),
      rightOption: ComparisonOptionDto.fromJson(
        json['rightOption'] as Map<String, dynamic>,
      ),
      category: json['category'] as String? ?? '',
      hasVoted: json['hasVoted'] as bool? ?? false,
    );
  }

  Comparison toDomain() => Comparison(
        id: id,
        titleTr: titleTr,
        titleEn: titleEn,
        leftOption: leftOption.toDomain(),
        rightOption: rightOption.toDomain(),
        category: category,
        hasVoted: hasVoted,
      );
}

class ComparisonFeedResponseDto {
  ComparisonFeedResponseDto({
    required this.items,
    required this.hasMore,
  });

  final List<ComparisonDto> items;
  final bool hasMore;

  factory ComparisonFeedResponseDto.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return ComparisonFeedResponseDto(
      items: itemsJson
          .map((e) => ComparisonDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  ComparisonFeedResponse toDomain() => ComparisonFeedResponse(
        items: items.map((e) => e.toDomain()).toList(),
        hasMore: hasMore,
      );
}

class ComparisonVoteOptionResultDto {
  ComparisonVoteOptionResultDto({
    required this.id,
    required this.voteCount,
    required this.percentage,
  });

  final String id;
  final int voteCount;
  final double percentage;

  factory ComparisonVoteOptionResultDto.fromJson(Map<String, dynamic> json) {
    return ComparisonVoteOptionResultDto(
      id: json['id'].toString(),
      voteCount: (json['voteCount'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  ComparisonVoteOptionResult toDomain() => ComparisonVoteOptionResult(
        id: id,
        voteCount: voteCount,
        percentage: percentage,
      );
}

class VotedComparisonDto {
  VotedComparisonDto({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.leftOption,
    required this.rightOption,
    required this.category,
    required this.selectedOptionId,
    required this.votedAt,
    required this.totalVotes,
    required this.leftResult,
    required this.rightResult,
  });

  final String id;
  final String titleTr;
  final String titleEn;
  final ComparisonOptionDto leftOption;
  final ComparisonOptionDto rightOption;
  final String category;
  final String selectedOptionId;
  final DateTime votedAt;
  final int totalVotes;
  final ComparisonVoteOptionResultDto leftResult;
  final ComparisonVoteOptionResultDto rightResult;

  factory VotedComparisonDto.fromJson(Map<String, dynamic> json) {
    return VotedComparisonDto(
      id: json['id'].toString(),
      titleTr: json['titleTr'] as String,
      titleEn: json['titleEn'] as String,
      leftOption: ComparisonOptionDto.fromJson(
        json['leftOption'] as Map<String, dynamic>,
      ),
      rightOption: ComparisonOptionDto.fromJson(
        json['rightOption'] as Map<String, dynamic>,
      ),
      category: json['category'] as String? ?? '',
      selectedOptionId: json['selectedOptionId'].toString(),
      votedAt: DateTime.parse(json['votedAt'] as String),
      totalVotes: (json['totalVotes'] as num).toInt(),
      leftResult: ComparisonVoteOptionResultDto.fromJson(
        json['leftResult'] as Map<String, dynamic>,
      ),
      rightResult: ComparisonVoteOptionResultDto.fromJson(
        json['rightResult'] as Map<String, dynamic>,
      ),
    );
  }

  VotedComparison toDomain() => VotedComparison(
        comparison: Comparison(
          id: id,
          titleTr: titleTr,
          titleEn: titleEn,
          leftOption: leftOption.toDomain(),
          rightOption: rightOption.toDomain(),
          category: category,
          hasVoted: true,
        ),
        selectedOptionId: selectedOptionId,
        votedAt: votedAt,
        voteResult: ComparisonVoteResult(
          comparisonId: id,
          selectedOptionId: selectedOptionId,
          totalVotes: totalVotes,
          leftOption: leftResult.toDomain(),
          rightOption: rightResult.toDomain(),
        ),
      );
}

class VotedComparisonsResponseDto {
  VotedComparisonsResponseDto({required this.items});

  final List<VotedComparisonDto> items;

  factory VotedComparisonsResponseDto.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return VotedComparisonsResponseDto(
      items: itemsJson
          .map((e) => VotedComparisonDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ComparisonVoteResultDto {
  ComparisonVoteResultDto({
    required this.comparisonId,
    required this.selectedOptionId,
    required this.totalVotes,
    required this.leftOption,
    required this.rightOption,
  });

  final String comparisonId;
  final String selectedOptionId;
  final int totalVotes;
  final ComparisonVoteOptionResultDto leftOption;
  final ComparisonVoteOptionResultDto rightOption;

  factory ComparisonVoteResultDto.fromJson(Map<String, dynamic> json) {
    return ComparisonVoteResultDto(
      comparisonId: json['comparisonId'] as String,
      selectedOptionId: json['selectedOptionId'] as String,
      totalVotes: (json['totalVotes'] as num).toInt(),
      leftOption: ComparisonVoteOptionResultDto.fromJson(
        json['leftOption'] as Map<String, dynamic>,
      ),
      rightOption: ComparisonVoteOptionResultDto.fromJson(
        json['rightOption'] as Map<String, dynamic>,
      ),
    );
  }

  ComparisonVoteResult toDomain() => ComparisonVoteResult(
        comparisonId: comparisonId,
        selectedOptionId: selectedOptionId,
        totalVotes: totalVotes,
        leftOption: leftOption.toDomain(),
        rightOption: rightOption.toDomain(),
      );
}
