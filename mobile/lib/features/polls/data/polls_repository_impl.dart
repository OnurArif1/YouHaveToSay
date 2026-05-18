import 'package:dio/dio.dart';

import '../domain/models/poll.dart';
import '../domain/polls_repository.dart';
import 'models/poll_dto.dart';

class PollsRepositoryImpl implements PollsRepository {
  PollsRepositoryImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<Poll> getNextPoll() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/polls/next');
      return PollDto.fromJson(response.data!).toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NoMorePollsException();
      }
      rethrow;
    }
  }

  @override
  Future<void> vote({
    required String pollId,
    required String optionId,
  }) async {
    await _dio.post<void>(
      '/api/polls/$pollId/vote',
      data: {'selectedOptionId': optionId},
    );
  }
}

class NoMorePollsException implements Exception {
  const NoMorePollsException();
}
