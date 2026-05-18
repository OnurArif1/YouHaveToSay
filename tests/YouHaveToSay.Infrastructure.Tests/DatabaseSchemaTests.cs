using Microsoft.EntityFrameworkCore;
using YouHaveToSay.Domain.Entities;
using YouHaveToSay.Infrastructure.Persistence;

namespace YouHaveToSay.Infrastructure.Tests;

public class DatabaseSchemaTests
{
    private const string ConnectionString =
        "Host=localhost;Port=5432;Database=YouHaveToSay;Username=postgres;Password=postgres";

    [Fact]
    public async Task SaveChanges_SetsAuditFieldsAutomatically()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var context = new AppDbContext(options);

        var user = new User
        {
            Id = Guid.NewGuid(),
            FirebaseUserId = "firebase-audit-test",
            Email = "audit@test.com"
        };

        context.Users.Add(user);
        await context.SaveChangesAsync();

        Assert.True(user.CreatedAt > DateTime.MinValue);
        Assert.True(user.IsActive);
    }

    [Fact]
    public async Task DuplicateVote_OnSamePoll_ThrowsDbUpdateException()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return; // Docker yoksa testi atla
        }

        await using var context = CreatePostgresContext();

        var userId = Guid.NewGuid();
        var pollId = Guid.NewGuid();
        var optionAId = Guid.NewGuid();
        var optionBId = Guid.NewGuid();

        context.Users.Add(new User
        {
            Id = userId,
            FirebaseUserId = $"firebase-{userId}",
            Email = $"user-{userId}@test.com"
        });

        context.Polls.Add(new Poll
        {
            Id = pollId,
            QuestionTr = "Test sorusu?",
            QuestionEn = "Test question?"
        });

        context.PollOptions.AddRange(
            new PollOption
            {
                Id = optionAId,
                PollId = pollId,
                OptionTextTr = "Evet",
                OptionTextEn = "Yes"
            },
            new PollOption
            {
                Id = optionBId,
                PollId = pollId,
                OptionTextTr = "Hayır",
                OptionTextEn = "No"
            });

        context.Votes.Add(new Vote
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            PollId = pollId,
            SelectedOptionId = optionAId
        });

        await context.SaveChangesAsync();

        context.Votes.Add(new Vote
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            PollId = pollId,
            SelectedOptionId = optionBId
        });

        await Assert.ThrowsAsync<DbUpdateException>(() => context.SaveChangesAsync());

        await using var cleanupContext = CreatePostgresContext();
        await CleanupTestDataAsync(cleanupContext, userId, pollId);
    }

    [Fact]
    public async Task FirebaseUserId_MustBeUnique()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return;
        }

        await using var context = CreatePostgresContext();

        var firebaseId = $"firebase-unique-{Guid.NewGuid()}";

        context.Users.Add(new User
        {
            Id = Guid.NewGuid(),
            FirebaseUserId = firebaseId,
            Email = "first@test.com"
        });

        await context.SaveChangesAsync();

        context.Users.Add(new User
        {
            Id = Guid.NewGuid(),
            FirebaseUserId = firebaseId,
            Email = "second@test.com"
        });

        await Assert.ThrowsAsync<DbUpdateException>(() => context.SaveChangesAsync());

        var users = context.Users.Where(u => u.FirebaseUserId == firebaseId).ToList();
        context.Users.RemoveRange(users);
        await context.SaveChangesAsync();
    }

    private static async Task CleanupTestDataAsync(AppDbContext context, Guid userId, Guid pollId)
    {
        context.Votes.RemoveRange(context.Votes.Where(v => v.UserId == userId));
        await context.SaveChangesAsync();

        context.PollOptions.RemoveRange(context.PollOptions.Where(o => o.PollId == pollId));
        context.Polls.Remove(context.Polls.Single(p => p.Id == pollId));
        context.Users.Remove(context.Users.Single(u => u.Id == userId));
        await context.SaveChangesAsync();
    }

    private static AppDbContext CreatePostgresContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseNpgsql(ConnectionString)
            .Options;

        return new AppDbContext(options);
    }

    private static async Task<bool> IsPostgresAvailableAsync()
    {
        try
        {
            await using var context = CreatePostgresContext();
            return await context.Database.CanConnectAsync();
        }
        catch
        {
            return false;
        }
    }
}
