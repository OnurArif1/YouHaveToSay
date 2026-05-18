import 'models/poll.dart';

abstract class PollsRepository {
  Future<Poll> getNextPoll();

  Future<void> vote({required String pollId, required String optionId});
}
