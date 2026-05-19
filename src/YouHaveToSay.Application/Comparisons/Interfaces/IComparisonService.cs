using YouHaveToSay.Application.Comparisons.Dtos;

namespace YouHaveToSay.Application.Comparisons.Interfaces;

public interface IComparisonService
{
    Task<ComparisonFeedResponseDto> GetFeedAsync(int limit, CancellationToken cancellationToken = default);

    Task<ComparisonVoteResultDto> VoteAsync(
        Guid comparisonId,
        Guid selectedOptionId,
        CancellationToken cancellationToken = default);

    Task<VotedComparisonsResponseDto> GetVotedHistoryAsync(
        int limit,
        CancellationToken cancellationToken = default);
}
