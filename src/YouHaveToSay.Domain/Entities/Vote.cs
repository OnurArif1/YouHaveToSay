using YouHaveToSay.Domain.Common;

namespace YouHaveToSay.Domain.Entities;

public class Vote : AuditableEntity
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public Guid PollId { get; set; }

    public Guid SelectedOptionId { get; set; }

    public User User { get; set; } = null!;

    public Poll Poll { get; set; } = null!;

    public PollOption SelectedOption { get; set; } = null!;
}
