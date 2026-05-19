using Microsoft.EntityFrameworkCore;
using YouHaveToSay.Application.Backoffice.Dtos;
using YouHaveToSay.Application.Backoffice.Interfaces;
using YouHaveToSay.Application.Backoffice.Validation;
using YouHaveToSay.Application.Common.Exceptions;
using YouHaveToSay.Domain.Entities;
using YouHaveToSay.Infrastructure.Persistence;

namespace YouHaveToSay.Infrastructure.Backoffice;

public class BackofficeComparisonService(AppDbContext dbContext) : IBackofficeComparisonService
{
    private const int MaxPageSize = 100;

    public async Task<BackofficeDashboardDto> GetDashboardAsync(CancellationToken cancellationToken = default)
    {
        var weekStart = DateTime.UtcNow.Date.AddDays(-(int)DateTime.UtcNow.DayOfWeek);

        var totalComparisons = await dbContext.Polls.CountAsync(cancellationToken);
        var activeComparisons = await dbContext.Polls.CountAsync(p => p.IsActive, cancellationToken);
        var totalVotes = await dbContext.Votes.CountAsync(v => v.IsActive, cancellationToken);
        var createdThisWeek = await dbContext.Polls.CountAsync(
            p => p.CreatedAt >= weekStart,
            cancellationToken);

        var voteCountsByPoll = await dbContext.Votes
            .AsNoTracking()
            .Where(v => v.IsActive)
            .GroupBy(v => v.PollId)
            .Select(g => new { PollId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        var voteLookup = voteCountsByPoll.ToDictionary(x => x.PollId, x => x.Count);

        var polls = await dbContext.Polls
            .AsNoTracking()
            .Include(p => p.Options)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync(cancellationToken);

        var listItems = polls
            .Select(p => MapListItem(p, voteLookup.GetValueOrDefault(p.Id, 0)))
            .ToList();

        var mostVoted = listItems
            .OrderByDescending(x => x.TotalVotes)
            .ThenByDescending(x => x.CreatedAt)
            .Take(10)
            .ToList();

        var latest = listItems
            .OrderByDescending(x => x.CreatedAt)
            .Take(10)
            .ToList();

        var averageVotes = totalComparisons == 0
            ? 0
            : Math.Round(totalVotes / (double)totalComparisons, 2);

        return new BackofficeDashboardDto
        {
            TotalComparisons = totalComparisons,
            ActiveComparisons = activeComparisons,
            InactiveComparisons = totalComparisons - activeComparisons,
            TotalVotes = totalVotes,
            ComparisonsCreatedThisWeek = createdThisWeek,
            AverageVotesPerComparison = averageVotes,
            MostVotedComparisons = mostVoted,
            LatestComparisons = latest
        };
    }

    public async Task<BackofficePagedResponse<BackofficeComparisonListItemDto>> GetComparisonsAsync(
        BackofficeComparisonQuery query,
        CancellationToken cancellationToken = default)
    {
        var page = Math.Max(1, query.Page);
        var pageSize = Math.Clamp(query.PageSize, 1, MaxPageSize);

        var voteCounts = await dbContext.Votes
            .AsNoTracking()
            .Where(v => v.IsActive)
            .GroupBy(v => v.PollId)
            .Select(g => new { PollId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        var voteLookup = voteCounts.ToDictionary(x => x.PollId, x => x.Count);

        var pollsQuery = dbContext.Polls
            .AsNoTracking()
            .Include(p => p.Options)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(query.Search))
        {
            var term = query.Search.Trim().ToLower();
            pollsQuery = pollsQuery.Where(p =>
                p.QuestionTr.ToLower().Contains(term) ||
                p.QuestionEn.ToLower().Contains(term) ||
                p.Options.Any(o =>
                    o.OptionTextTr.ToLower().Contains(term) ||
                    o.OptionTextEn.ToLower().Contains(term)));
        }

        if (!string.IsNullOrWhiteSpace(query.Category))
        {
            var category = query.Category.Trim().ToLower();
            pollsQuery = pollsQuery.Where(p => p.Category.ToLower() == category);
        }

        if (query.IsActive.HasValue)
        {
            pollsQuery = pollsQuery.Where(p => p.IsActive == query.IsActive.Value);
        }

        var sortBy = query.SortBy?.Trim().ToLowerInvariant() ?? "createdat";
        var desc = !string.Equals(query.SortDirection, "asc", StringComparison.OrdinalIgnoreCase);

        var polls = await pollsQuery.ToListAsync(cancellationToken);

        var items = polls
            .Select(p => MapListItem(p, voteLookup.GetValueOrDefault(p.Id, 0)))
            .ToList();

        items = sortBy switch
        {
            "totalvotes" or "votes" => desc
                ? items.OrderByDescending(x => x.TotalVotes).ThenByDescending(x => x.CreatedAt).ToList()
                : items.OrderBy(x => x.TotalVotes).ThenBy(x => x.CreatedAt).ToList(),
            _ => desc
                ? items.OrderByDescending(x => x.CreatedAt).ToList()
                : items.OrderBy(x => x.CreatedAt).ToList()
        };

        var totalCount = items.Count;
        var pageItems = items.Skip((page - 1) * pageSize).Take(pageSize).ToList();

        return new BackofficePagedResponse<BackofficeComparisonListItemDto>
        {
            Items = pageItems,
            Page = page,
            PageSize = pageSize,
            TotalCount = totalCount
        };
    }

    public async Task<BackofficeComparisonDetailDto> GetComparisonDetailAsync(
        Guid id,
        CancellationToken cancellationToken = default)
    {
        var poll = await LoadPollWithOptionsAsync(id, cancellationToken);
        return MapDetail(poll);
    }

    public async Task<Guid> CreateComparisonAsync(
        CreateComparisonRequest request,
        CancellationToken cancellationToken = default)
    {
        BackofficeComparisonValidator.ValidateCreate(request);

        var pollId = Guid.NewGuid();
        var poll = new Poll
        {
            Id = pollId,
            QuestionTr = request.TitleTr.Trim(),
            QuestionEn = string.IsNullOrWhiteSpace(request.TitleEn)
                ? request.TitleTr.Trim()
                : request.TitleEn.Trim(),
            Category = request.Category.Trim(),
            IsActive = request.IsActive,
            Options =
            [
                CreateOption(pollId, request.LeftOption, 1),
                CreateOption(pollId, request.RightOption, 2)
            ]
        };

        dbContext.Polls.Add(poll);
        await dbContext.SaveChangesAsync(cancellationToken);
        return pollId;
    }

    public async Task UpdateComparisonAsync(
        Guid id,
        UpdateComparisonRequest request,
        CancellationToken cancellationToken = default)
    {
        BackofficeComparisonValidator.ValidateUpdate(request);

        var poll = await LoadPollWithOptionsAsync(id, cancellationToken, tracking: true);

        poll.QuestionTr = request.TitleTr.Trim();
        poll.QuestionEn = string.IsNullOrWhiteSpace(request.TitleEn)
            ? request.TitleTr.Trim()
            : request.TitleEn.Trim();
        poll.Category = request.Category.Trim();

        var options = poll.Options.OrderBy(o => o.CreatedAt).ToList();
        if (options.Count != 2)
        {
            throw new BadRequestAppException("Comparison must have exactly two options.");
        }

        ApplyOptionUpdate(options[0], request.LeftOption);
        ApplyOptionUpdate(options[1], request.RightOption);

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateComparisonStatusAsync(
        Guid id,
        UpdateComparisonStatusRequest request,
        CancellationToken cancellationToken = default)
    {
        var poll = await dbContext.Polls.FirstOrDefaultAsync(p => p.Id == id, cancellationToken)
            ?? throw new NotFoundAppException("Comparison not found.");

        poll.IsActive = request.IsActive;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<ComparisonResultDto> GetComparisonResultsAsync(
        Guid id,
        CancellationToken cancellationToken = default)
    {
        var poll = await LoadPollWithOptionsAsync(id, cancellationToken);
        var options = poll.Options.OrderBy(o => o.CreatedAt).Take(2).ToList();

        if (options.Count != 2)
        {
            throw new BadRequestAppException("Comparison must have exactly two options.");
        }

        var voteCounts = await dbContext.Votes
            .AsNoTracking()
            .Where(v => v.PollId == id && v.IsActive)
            .GroupBy(v => v.SelectedOptionId)
            .Select(g => new { OptionId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        var leftCount = voteCounts.FirstOrDefault(x => x.OptionId == options[0].Id)?.Count ?? 0;
        var rightCount = voteCounts.FirstOrDefault(x => x.OptionId == options[1].Id)?.Count ?? 0;
        var totalVotes = leftCount + rightCount;

        return new ComparisonResultDto
        {
            ComparisonId = poll.Id,
            TitleTr = poll.QuestionTr,
            TitleEn = poll.QuestionEn,
            TotalVotes = totalVotes,
            Options =
            [
                ToOptionResult(options[0], leftCount, totalVotes),
                ToOptionResult(options[1], rightCount, totalVotes)
            ]
        };
    }

    public async Task<IReadOnlyList<string>> GetCategoriesAsync(CancellationToken cancellationToken = default)
    {
        return await dbContext.Polls
            .AsNoTracking()
            .Where(p => p.Category != string.Empty)
            .Select(p => p.Category)
            .Distinct()
            .OrderBy(c => c)
            .ToListAsync(cancellationToken);
    }

    private async Task<Poll> LoadPollWithOptionsAsync(
        Guid id,
        CancellationToken cancellationToken,
        bool tracking = false)
    {
        var query = dbContext.Polls.Include(p => p.Options).AsQueryable();
        if (!tracking)
        {
            query = query.AsNoTracking();
        }

        return await query.FirstOrDefaultAsync(p => p.Id == id, cancellationToken)
            ?? throw new NotFoundAppException("Comparison not found.");
    }

    private static PollOption CreateOption(Guid pollId, ComparisonOptionInput input, int displayOrder)
    {
        return new PollOption
        {
            Id = Guid.NewGuid(),
            PollId = pollId,
            OptionTextTr = input.TextTr.Trim(),
            OptionTextEn = string.IsNullOrWhiteSpace(input.TextEn)
                ? input.TextTr.Trim()
                : input.TextEn.Trim(),
            ImageUrl = NormalizeImageUrl(input.ImageUrl)
        };
    }

    private static void ApplyOptionUpdate(PollOption option, ComparisonOptionInput input)
    {
        option.OptionTextTr = input.TextTr.Trim();
        option.OptionTextEn = string.IsNullOrWhiteSpace(input.TextEn)
            ? input.TextTr.Trim()
            : input.TextEn.Trim();
        option.ImageUrl = NormalizeImageUrl(input.ImageUrl);
    }

    private static string? NormalizeImageUrl(string? imageUrl) =>
        string.IsNullOrWhiteSpace(imageUrl) ? null : imageUrl.Trim();

    private static BackofficeComparisonListItemDto MapListItem(Poll poll, int totalVotes)
    {
        var options = poll.Options.OrderBy(o => o.CreatedAt).ToList();
        var left = options.ElementAtOrDefault(0);
        var right = options.ElementAtOrDefault(1);

        return new BackofficeComparisonListItemDto
        {
            Id = poll.Id,
            TitleTr = poll.QuestionTr,
            TitleEn = poll.QuestionEn,
            Category = poll.Category,
            IsActive = poll.IsActive,
            CreatedAt = poll.CreatedAt,
            OptionCount = options.Count,
            TotalVotes = totalVotes,
            LeftOptionText = left?.OptionTextTr ?? string.Empty,
            RightOptionText = right?.OptionTextTr ?? string.Empty
        };
    }

    private static BackofficeComparisonDetailDto MapDetail(Poll poll)
    {
        var options = poll.Options.OrderBy(o => o.CreatedAt).Select((o, index) => new BackofficeComparisonOptionDto
        {
            Id = o.Id,
            TextTr = o.OptionTextTr,
            TextEn = o.OptionTextEn,
            ImageUrl = o.ImageUrl,
            DisplayOrder = index + 1
        }).ToList();

        return new BackofficeComparisonDetailDto
        {
            Id = poll.Id,
            TitleTr = poll.QuestionTr,
            TitleEn = poll.QuestionEn,
            Category = poll.Category,
            IsActive = poll.IsActive,
            CreatedAt = poll.CreatedAt,
            Options = options
        };
    }

    private static ComparisonOptionResultDto ToOptionResult(PollOption option, int voteCount, int totalVotes)
    {
        var percentage = totalVotes == 0 ? 0 : Math.Round(voteCount * 100.0 / totalVotes, 2);
        return new ComparisonOptionResultDto
        {
            OptionId = option.Id,
            TextTr = option.OptionTextTr,
            TextEn = option.OptionTextEn,
            VoteCount = voteCount,
            Percentage = percentage
        };
    }
}
