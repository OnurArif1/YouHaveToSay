import 'package:dio/dio.dart';

import '../domain/comparison_repository.dart';
import '../domain/models/comparison_feed_response.dart';
import '../domain/models/comparison_vote_result.dart';
import '../domain/models/voted_comparison.dart';
import 'models/comparison_dto.dart';

class ComparisonRepositoryException implements Exception {
  const ComparisonRepositoryException(this.message, {this.code});

  final String message;
  final String? code;
}

class AlreadyVotedException extends ComparisonRepositoryException {
  const AlreadyVotedException() : super('Already voted', code: 'ALREADY_VOTED');
}

class ComparisonRepositoryImpl implements ComparisonRepository {
  ComparisonRepositoryImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<ComparisonFeedResponse> getComparisonFeed({int limit = 10}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/comparisons/feed',
        queryParameters: {'limit': limit},
      );
      return ComparisonFeedResponseDto.fromJson(response.data!).toDomain();
    } on DioException catch (e) {
      throw _mapDioError(e, fallback: 'feed_load_error');
    }
  }

  @override
  Future<ComparisonVoteResult> voteComparison({
    required String comparisonId,
    required String selectedOptionId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/comparisons/$comparisonId/vote',
        data: {'selectedOptionId': selectedOptionId},
      );
      return ComparisonVoteResultDto.fromJson(response.data!).toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const AlreadyVotedException();
      }
      throw _mapDioError(e, fallback: 'vote_error');
    }
  }

  @override
  Future<List<VotedComparison>> getVotedHistory({int limit = 50}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/comparisons/voted',
        queryParameters: {'limit': limit},
      );
      final dto = VotedComparisonsResponseDto.fromJson(response.data!);
      return dto.items.map((e) => e.toDomain()).toList();
    } on DioException catch (e) {
      throw _mapDioError(e, fallback: 'voted_history_error');
    }
  }

  ComparisonRepositoryException _mapDioError(
    DioException e, {
    required String fallback,
  }) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'] as String?;
      final message = data['message'] as String? ?? fallback;
      if (code == 'ALREADY_VOTED') {
        return const AlreadyVotedException();
      }
      return ComparisonRepositoryException(message, code: code);
    }
    return ComparisonRepositoryException(fallback);
  }
}
