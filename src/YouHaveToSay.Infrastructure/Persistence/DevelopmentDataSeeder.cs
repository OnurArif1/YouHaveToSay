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
        if (!env.IsDevelopment() && !env.IsEnvironment("Testing"))
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

        var baseTime = DateTime.UtcNow;
        var index = 0;

        var polls = new List<Poll>();

        void Add(string category, string questionTr, string questionEn, (string Tr, string En) left, (string Tr, string En) right)
        {
            polls.Add(CreatePoll(
                category,
                questionTr,
                questionEn,
                left,
                right,
                baseTime.AddMinutes(-index)));
            index++;
        }

        // Colors (6)
        Add("colors", "Hangisini seçerdin?", "Which one would you choose?", ("Mavi", "Blue"), ("Kırmızı", "Red"));
        Add("colors", "Hangisi daha çekici?", "Which is more attractive?", ("Yeşil", "Green"), ("Mor", "Purple"));
        Add("colors", "Hangisini giyerdin?", "Which would you wear?", ("Siyah", "Black"), ("Beyaz", "White"));
        Add("colors", "Hangisi daha enerjik?", "Which feels more energetic?", ("Turuncu", "Orange"), ("Sarı", "Yellow"));
        Add("colors", "Hangisi daha sakin?", "Which feels calmer?", ("Lacivert", "Navy"), ("Gri", "Grey"));
        Add("colors", "Hangisi daha cesur?", "Which is bolder?", ("Pembe", "Pink"), ("Altın", "Gold"));

        // Cars (6)
        Add("cars", "Hangisini kullanırdın?", "Which would you drive?", ("Opel", "Opel"), ("Mercedes", "Mercedes"));
        Add("cars", "Hangisi daha sportif?", "Which is sportier?", ("BMW", "BMW"), ("Audi", "Audi"));
        Add("cars", "Hangisi daha pratik?", "Which is more practical?", ("Renault", "Renault"), ("Volkswagen", "Volkswagen"));
        Add("cars", "Hangisi daha ekonomik?", "Which is more economical?", ("Fiat", "Fiat"), ("Toyota", "Toyota"));
        Add("cars", "Hangisi daha lüks?", "Which is more luxurious?", ("Porsche", "Porsche"), ("Ferrari", "Ferrari"));
        Add("cars", "Hangisi daha güvenilir?", "Which feels more reliable?", ("Honda", "Honda"), ("Hyundai", "Hyundai"));

        // Football (6)
        Add("football", "Hangisi daha iyi forvet?", "Who is the better striker?", ("İcardi", "Icardi"), ("Osimhen", "Osimhen"));
        Add("football", "Hangisi daha büyük efsane?", "Who is the bigger legend?", ("Messi", "Messi"), ("Ronaldo", "Ronaldo"));
        Add("football", "Hangisi daha iyi kaleci?", "Who is the better goalkeeper?", ("Muslera", "Muslera"), ("Livakovic", "Livakovic"));
        Add("football", "Hangisi daha iyi teknik direktör?", "Who is the better coach?", ("Ancelotti", "Ancelotti"), ("Guardiola", "Guardiola"));
        Add("football", "Hangisi daha iyi orta saha?", "Who is the better midfielder?", ("Modric", "Modric"), ("De Bruyne", "De Bruyne"));
        Add("football", "Hangisi daha iyi savunmacı?", "Who is the better defender?", ("Ramos", "Ramos"), ("Van Dijk", "Van Dijk"));

        // Food (6)
        Add("food", "Hangisini içerdin?", "Which would you drink?", ("Çay", "Tea"), ("Kahve", "Coffee"));
        Add("food", "Hangisi daha lezzetli?", "Which tastes better?", ("Döner", "Doner"), ("Lahmacun", "Lahmacun"));
        Add("food", "Hangisi daha sağlıklı?", "Which is healthier?", ("Salata", "Salad"), ("Çorba", "Soup"));
        Add("food", "Hangisi daha tatlı?", "Which is sweeter?", ("Baklava", "Baklava"), ("Künefe", "Kunefe"));
        Add("food", "Hangisi kahvaltıda?", "Which for breakfast?", ("Simit", "Simit"), ("Poğaça", "Pogaca"));
        Add("food", "Hangisi akşam yemeğinde?", "Which for dinner?", ("Mantı", "Manti"), ("Pide", "Pide"));

        // Technology (6)
        Add("technology", "Hangisini alırdın?", "Which would you buy?", ("iPhone", "iPhone"), ("Samsung", "Samsung"));
        Add("technology", "Hangisi daha üretken?", "Which is more productive?", ("MacBook", "MacBook"), ("Windows Laptop", "Windows Laptop"));
        Add("technology", "Hangisi daha iyi oyun?", "Which is better for gaming?", ("PlayStation", "PlayStation"), ("Xbox", "Xbox"));
        Add("technology", "Hangisi daha kullanışlı?", "Which is more useful?", ("iPad", "iPad"), ("Android Tablet", "Android Tablet"));
        Add("technology", "Hangisi daha iyi kulaklık?", "Which headphones are better?", ("AirPods", "AirPods"), ("Sony WH", "Sony WH"));
        Add("technology", "Hangisi daha iyi akıllı saat?", "Which smartwatch is better?", ("Apple Watch", "Apple Watch"), ("Galaxy Watch", "Galaxy Watch"));

        // Daily Life (6)
        Add("daily_life", "Hangisini tercih ederdin?", "Which do you prefer?", ("Yaz", "Summer"), ("Kış", "Winter"));
        Add("daily_life", "Hangisi daha rahat?", "Which is more comfortable?", ("Evde kalmak", "Stay home"), ("Dışarı çıkmak", "Go out"));
        Add("daily_life", "Hangisi daha erken?", "Which is earlier?", ("Sabah insanı", "Morning person"), ("Gece kuşu", "Night owl"));
        Add("daily_life", "Hangisi daha iyi tatil?", "Which is the better vacation?", ("Deniz", "Beach"), ("Dağ", "Mountain"));
        Add("daily_life", "Hangisi daha pratik ulaşım?", "Which transport is more practical?", ("Metro", "Metro"), ("Araba", "Car"));
        Add("daily_life", "Hangisi daha iyi hafta sonu?", "Which is the better weekend?", ("Kitap okumak", "Read a book"), ("Dizi izlemek", "Watch a series"));

        db.Polls.AddRange(polls);
        await db.SaveChangesAsync(cancellationToken);
        logger.LogInformation("Seeded {Count} development comparisons.", polls.Count);
    }

    private static Poll CreatePoll(
        string category,
        string questionTr,
        string questionEn,
        (string Tr, string En) left,
        (string Tr, string En) right,
        DateTime createdAt)
    {
        var pollId = Guid.NewGuid();
        var poll = new Poll
        {
            Id = pollId,
            QuestionTr = questionTr,
            QuestionEn = questionEn,
            Category = category,
            CreatedAt = createdAt
        };

        poll.Options =
        [
            new PollOption
            {
                Id = Guid.NewGuid(),
                PollId = pollId,
                OptionTextTr = left.Tr,
                OptionTextEn = left.En,
                CreatedAt = createdAt
            },
            new PollOption
            {
                Id = Guid.NewGuid(),
                PollId = pollId,
                OptionTextTr = right.Tr,
                OptionTextEn = right.En,
                CreatedAt = createdAt.AddSeconds(1)
            }
        ];

        return poll;
    }
}
