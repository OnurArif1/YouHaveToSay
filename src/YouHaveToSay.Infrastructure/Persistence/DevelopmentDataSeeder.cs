using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using YouHaveToSay.Domain.Entities;

namespace YouHaveToSay.Infrastructure.Persistence;

public static class DevelopmentDataSeeder
{
    public static async Task SeedAsync(IServiceProvider services, CancellationToken cancellationToken = default)
    {
        var env = services.GetRequiredService<IHostEnvironment>();
        if (!env.IsDevelopment())
        {
            return;
        }

        await using var scope = services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<AppDbContext>>();

        if (await db.Polls.AnyAsync(cancellationToken))
        {
            return;
        }

        var polls = new[]
        {
            CreatePoll(
                "Türkiye'de en çok konuşulan gündem hangisi?",
                "What is the hottest topic in Turkey right now?",
                ("Ekonomi", "Economy"),
                ("Siyaset", "Politics"),
                ("Spor", "Sports")),
            CreatePoll(
                "Hafta sonu ne yapmayı tercih edersin?",
                "What do you prefer to do on the weekend?",
                ("Evde dinlenmek", "Stay home and relax"),
                ("Dışarı çıkmak", "Go out"),
                ("Seyahat", "Travel")),
            CreatePoll(
                "Kahve mi çay mı?",
                "Coffee or tea?",
                ("Kahve", "Coffee"),
                ("Çay", "Tea"))
        };

        db.Polls.AddRange(polls);
        await db.SaveChangesAsync(cancellationToken);
        logger.LogInformation("Seeded {Count} development polls.", polls.Length);
    }

    private static Poll CreatePoll(string questionTr, string questionEn, params (string Tr, string En)[] options)
    {
        var pollId = Guid.NewGuid();
        var poll = new Poll
        {
            Id = pollId,
            QuestionTr = questionTr,
            QuestionEn = questionEn
        };

        poll.Options = options.Select(o => new PollOption
        {
            Id = Guid.NewGuid(),
            PollId = pollId,
            OptionTextTr = o.Tr,
            OptionTextEn = o.En
        }).ToList();

        return poll;
    }
}
