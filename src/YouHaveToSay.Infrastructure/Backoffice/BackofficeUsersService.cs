using Microsoft.EntityFrameworkCore;
using YouHaveToSay.Application.Backoffice.Dtos;
using YouHaveToSay.Application.Backoffice.Interfaces;
using YouHaveToSay.Infrastructure.Persistence;

namespace YouHaveToSay.Infrastructure.Backoffice;

public class BackofficeUsersService(AppDbContext dbContext) : IBackofficeUsersService
{
    public async Task<BackofficeUsersSummaryDto> GetSummaryAsync(CancellationToken cancellationToken = default)
    {
        var weekStart = DateTime.UtcNow.Date.AddDays(-(int)DateTime.UtcNow.DayOfWeek);

        var totalUsers = await dbContext.Users.CountAsync(cancellationToken);
        var newUsersThisWeek = await dbContext.Users.CountAsync(
            u => u.CreatedAt >= weekStart,
            cancellationToken);

        var totalVotes = await dbContext.Votes.CountAsync(v => v.IsActive, cancellationToken);
        var totalVoters = await dbContext.Votes
            .Where(v => v.IsActive)
            .Select(v => v.UserId)
            .Distinct()
            .CountAsync(cancellationToken);

        var voterStats = await dbContext.Votes
            .AsNoTracking()
            .Where(v => v.IsActive)
            .GroupBy(v => v.UserId)
            .Select(g => new
            {
                UserId = g.Key,
                VoteCount = g.Count(),
                LastVoteAt = g.Max(v => v.CreatedAt)
            })
            .OrderByDescending(x => x.VoteCount)
            .Take(20)
            .ToListAsync(cancellationToken);

        var userIds = voterStats.Select(v => v.UserId).ToList();
        var users = await dbContext.Users
            .AsNoTracking()
            .Where(u => userIds.Contains(u.Id))
            .ToDictionaryAsync(u => u.Id, cancellationToken);

        var topVoters = voterStats
            .Where(v => users.ContainsKey(v.UserId))
            .Select(v => new BackofficeUserActivityDto
            {
                Email = users[v.UserId].Email,
                TotalVotes = v.VoteCount,
                CreatedAt = users[v.UserId].CreatedAt,
                LastVoteAt = v.LastVoteAt
            })
            .ToList();

        var averageVotes = totalVoters == 0 ? 0 : Math.Round(totalVotes / (double)totalVoters, 2);
        var mostActiveThreshold = voterStats.FirstOrDefault()?.VoteCount ?? 0;
        var mostActiveCount = voterStats.Count(v => v.VoteCount == mostActiveThreshold && mostActiveThreshold > 0);

        return new BackofficeUsersSummaryDto
        {
            TotalUsers = totalUsers,
            TotalVoters = totalVoters,
            TotalVotes = totalVotes,
            AverageVotesPerUser = averageVotes,
            MostActiveVotersCount = mostActiveCount,
            NewUsersThisWeek = newUsersThisWeek,
            TopVoters = topVoters
        };
    }
}
