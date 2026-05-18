using Microsoft.EntityFrameworkCore;
using YouHaveToSay.Application.Common.Exceptions;
using YouHaveToSay.Application.Common.Interfaces;
using YouHaveToSay.Application.Polls.Dtos;
using YouHaveToSay.Application.Polls.Interfaces;
using YouHaveToSay.Domain.Entities;
using YouHaveToSay.Infrastructure.Persistence;

namespace YouHaveToSay.Infrastructure.Polls;

public class PollService(AppDbContext dbContext, ICurrentUserService currentUser) : IPollService
{
    public async Task<PollDto> GetNextPollAsync(CancellationToken cancellationToken = default)
    {
        var userId = RequireUserId();

        var votedPollIds = dbContext.Votes
            .Where(v => v.UserId == userId && v.IsActive)
            .Select(v => v.PollId);

        var poll = await dbContext.Polls
            .AsNoTracking()
            .Where(p => p.IsActive && !votedPollIds.Contains(p.Id))
            .OrderByDescending(p => p.CreatedAt)
            .Include(p => p.Options.Where(o => o.IsActive))
            .FirstOrDefaultAsync(cancellationToken);

        if (poll is null)
        {
            throw new NotFoundAppException("No more polls available.", "NO_MORE_POLLS");
        }

        return MapToDto(poll);
    }

    public async Task VoteAsync(Guid pollId, Guid selectedOptionId, CancellationToken cancellationToken = default)
    {
        var userId = RequireUserId();

        var poll = await dbContext.Polls
            .Include(p => p.Options)
            .FirstOrDefaultAsync(p => p.Id == pollId && p.IsActive, cancellationToken);

        if (poll is null)
        {
            throw new NotFoundAppException("Poll not found.");
        }

        var option = poll.Options.FirstOrDefault(o => o.Id == selectedOptionId && o.IsActive);
        if (option is null)
        {
            throw new BadRequestAppException("Selected option is invalid for this poll.");
        }

        var alreadyVoted = await dbContext.Votes
            .AnyAsync(v => v.UserId == userId && v.PollId == pollId, cancellationToken);

        if (alreadyVoted)
        {
            throw new ConflictAppException("You have already voted on this poll.", "ALREADY_VOTED");
        }

        var vote = new Vote
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            PollId = pollId,
            SelectedOptionId = selectedOptionId
        };

        dbContext.Votes.Add(vote);

        try
        {
            await dbContext.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            throw new ConflictAppException("You have already voted on this poll.", "ALREADY_VOTED");
        }
    }

    private Guid RequireUserId()
    {
        if (!currentUser.IsAuthenticated || currentUser.UserId is null)
        {
            throw new UnauthorizedAppException();
        }

        return currentUser.UserId.Value;
    }

    private static PollDto MapToDto(Poll poll) => new()
    {
        Id = poll.Id,
        QuestionTr = poll.QuestionTr,
        QuestionEn = poll.QuestionEn,
        Options = poll.Options
            .OrderBy(o => o.CreatedAt)
            .Select(o => new PollOptionDto
            {
                Id = o.Id,
                OptionTextTr = o.OptionTextTr,
                OptionTextEn = o.OptionTextEn
            })
            .ToList()
    };
}
