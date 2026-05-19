using YouHaveToSay.Domain.Common;

namespace YouHaveToSay.Domain.Entities;

public class PollOption : AuditableEntity
{
    public Guid Id { get; set; }

    public Guid PollId { get; set; }

    public string OptionTextTr { get; set; } = null!;

    public string OptionTextEn { get; set; } = null!;

    public string? ImageUrl { get; set; }

    public Poll Poll { get; set; } = null!;

    public ICollection<Vote> Votes { get; set; } = new List<Vote>();
}
