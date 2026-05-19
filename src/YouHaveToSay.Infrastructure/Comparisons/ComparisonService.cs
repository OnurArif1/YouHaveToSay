using Microsoft.EntityFrameworkCore;
using YouHaveToSay.Application.Common.Exceptions;
using YouHaveToSay.Application.Common.Interfaces;
using YouHaveToSay.Application.Comparisons.Dtos;
using YouHaveToSay.Application.Comparisons.Interfaces;
using YouHaveToSay.Domain.Entities;
using YouHaveToSay.Infrastructure.Persistence;

namespace YouHaveToSay.Infrastructure.Comparisons;

public class ComparisonService(AppDbContext dbContext, ICurrentUserService currentUser) : IComparisonService
{
    private const int DefaultLimit = 10;
    private const int MaxLimit = 25;
    private const int DefaultHistoryLimit = 50;
    private const int MaxHistoryLimit = 100;

    public async Task<ComparisonFeedResponseDto> GetFeedAsync(
        int limit,
        CancellationToken cancellationToken = default)
    {
        _ = RequireUserId();
        var effectiveLimit = NormalizeLimit(limit);

        var votedPollIds = dbContext.Votes
            .Where(v => v.UserId == currentUser.UserId && v.IsActive)
            .Select(v => v.PollId);

        var polls = await dbContext.Polls
            .AsNoTracking()
            .Where(p => p.IsActive && !votedPollIds.Contains(p.Id))
            .Where(p => p.Options.Count(o => o.IsActive) == 2)
            .OrderByDescending(p => p.CreatedAt)
            .Include(p => p.Options.Where(o => o.IsActive).OrderBy(o => o.CreatedAt))
            .Take(effectiveLimit + 1)
            .ToListAsync(cancellationToken);

        var hasMore = polls.Count > effectiveLimit;
        var page = polls.Take(effectiveLimit).Select(MapToComparisonDto).ToList();

        return new ComparisonFeedResponseDto
        {
            Items = page,
            HasMore = hasMore
        };
    }

    public async Task<ComparisonVoteResultDto> VoteAsync(
        Guid comparisonId,
        Guid selectedOptionId,
        CancellationToken cancellationToken = default)
    {
        var userId = RequireUserId();

        var poll = await dbContext.Polls
            .Include(p => p.Options)
            .FirstOrDefaultAsync(p => p.Id == comparisonId && p.IsActive, cancellationToken);

        if (poll is null)
        {
            throw new NotFoundAppException("Comparison not found.");
        }

        var activeOptions = poll.Options.Where(o => o.IsActive).OrderBy(o => o.CreatedAt).ToList();
        if (activeOptions.Count != 2)
        {
            throw new BadRequestAppException("Comparison must have exactly two active options.");
        }

        if (activeOptions.All(o => o.Id != selectedOptionId))
        {
            throw new BadRequestAppException("Selected option is invalid for this comparison.");
        }

        var alreadyVoted = await dbContext.Votes
            .AnyAsync(v => v.UserId == userId && v.PollId == comparisonId, cancellationToken);

        if (alreadyVoted)
        {
            throw new ConflictAppException("You have already voted on this comparison.", "ALREADY_VOTED");
        }

        dbContext.Votes.Add(new Vote
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            PollId = comparisonId,
            SelectedOptionId = selectedOptionId
        });

        try
        {
            await dbContext.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            throw new ConflictAppException("You have already voted on this comparison.", "ALREADY_VOTED");
        }

        return await BuildVoteResultAsync(comparisonId, activeOptions, selectedOptionId, cancellationToken);
    }

    public async Task<VotedComparisonsResponseDto> GetVotedHistoryAsync(
        int limit,
        CancellationToken cancellationToken = default)
    {
        var userId = RequireUserId();
        var effectiveLimit = NormalizeHistoryLimit(limit);

        var votes = await dbContext.Votes
            .AsNoTracking()
            .Where(v => v.UserId == userId && v.IsActive)
            .OrderByDescending(v => v.CreatedAt)
            .Include(v => v.Poll)
            .ThenInclude(p => p.Options)
            .Take(effectiveLimit * 2)
            .ToListAsync(cancellationToken);

        var items = new List<VotedComparisonDto>();

        foreach (var vote in votes)
        {
            if (items.Count >= effectiveLimit)
            {
                break;
            }

            var poll = vote.Poll;
            if (!poll.IsActive)
            {
                continue;
            }

            var activeOptions = poll.Options.Where(o => o.IsActive).OrderBy(o => o.CreatedAt).ToList();
            if (activeOptions.Count != 2)
            {
                continue;
            }

            var result = await BuildVoteResultAsync(
                poll.Id,
                activeOptions,
                vote.SelectedOptionId,
                cancellationToken);

            items.Add(new VotedComparisonDto
            {
                Id = poll.Id,
                TitleTr = poll.QuestionTr,
                TitleEn = poll.QuestionEn,
                LeftOption = MapOption(activeOptions[0]),
                RightOption = MapOption(activeOptions[1]),
                Category = poll.Category,
                SelectedOptionId = vote.SelectedOptionId,
                VotedAt = vote.CreatedAt,
                TotalVotes = result.TotalVotes,
                LeftResult = result.LeftOption,
                RightResult = result.RightOption
            });
        }

        return new VotedComparisonsResponseDto { Items = items };
    }

    private async Task<ComparisonVoteResultDto> BuildVoteResultAsync(
        Guid comparisonId,
        List<PollOption> activeOptions,
        Guid selectedOptionId,
        CancellationToken cancellationToken)
    {
        var left = activeOptions[0];
        var right = activeOptions[1];

        var voteCounts = await dbContext.Votes
            .AsNoTracking()
            .Where(v => v.PollId == comparisonId && v.IsActive)
            .GroupBy(v => v.SelectedOptionId)
            .Select(g => new { OptionId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        var leftCount = voteCounts.FirstOrDefault(x => x.OptionId == left.Id)?.Count ?? 0;
        var rightCount = voteCounts.FirstOrDefault(x => x.OptionId == right.Id)?.Count ?? 0;
        var totalVotes = leftCount + rightCount;

        return new ComparisonVoteResultDto
        {
            ComparisonId = comparisonId,
            SelectedOptionId = selectedOptionId,
            TotalVotes = totalVotes,
            LeftOption = ToOptionResult(left.Id, leftCount, totalVotes),
            RightOption = ToOptionResult(right.Id, rightCount, totalVotes)
        };
    }

    private static ComparisonVoteOptionResultDto ToOptionResult(Guid optionId, int voteCount, int totalVotes)
    {
        var percentage = totalVotes == 0 ? 0 : Math.Round(voteCount * 100.0 / totalVotes, 2);
        return new ComparisonVoteOptionResultDto
        {
            Id = optionId,
            VoteCount = voteCount,
            Percentage = percentage
        };
    }

    private Guid RequireUserId()
    {
        if (!currentUser.IsAuthenticated || currentUser.UserId is null)
        {
            throw new UnauthorizedAppException();
        }

        return currentUser.UserId.Value;
    }

    private static int NormalizeLimit(int limit)
    {
        if (limit < 1)
        {
            return DefaultLimit;
        }

        return Math.Min(limit, MaxLimit);
    }

    private static int NormalizeHistoryLimit(int limit)
    {
        if (limit < 1)
        {
            return DefaultHistoryLimit;
        }

        return Math.Min(limit, MaxHistoryLimit);
    }

    internal static ComparisonDto MapToComparisonDto(Poll poll)
    {
        var options = poll.Options.OrderBy(o => o.CreatedAt).ToList();
        var left = options[0];
        var right = options[1];

        return new ComparisonDto
        {
            Id = poll.Id,
            TitleTr = poll.QuestionTr,
            TitleEn = poll.QuestionEn,
            LeftOption = MapOption(left),
            RightOption = MapOption(right),
            Category = poll.Category,
            HasVoted = false
        };
    }

    private static ComparisonOptionDto MapOption(PollOption option) => new()
    {
        Id = option.Id,
        TextTr = option.OptionTextTr,
        TextEn = option.OptionTextEn,
        ImageUrl = null
    };
}
