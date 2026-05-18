using YouHaveToSay.Application.Polls.Dtos;

namespace YouHaveToSay.Application.Polls.Interfaces;

public interface IPollService
{
    Task<PollDto> GetNextPollAsync(CancellationToken cancellationToken = default);

    Task VoteAsync(Guid pollId, Guid selectedOptionId, CancellationToken cancellationToken = default);
}
