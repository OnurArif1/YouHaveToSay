using YouHaveToSay.Domain.Common;

namespace YouHaveToSay.Domain.Entities;

public class Poll : AuditableEntity
{
    public Guid Id { get; set; }

    public string QuestionTr { get; set; } = null!;

    public string QuestionEn { get; set; } = null!;

    public string Category { get; set; } = string.Empty;

    public ICollection<PollOption> Options { get; set; } = new List<PollOption>();

    public ICollection<Vote> Votes { get; set; } = new List<Vote>();
}
