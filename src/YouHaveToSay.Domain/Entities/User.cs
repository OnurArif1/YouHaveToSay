using YouHaveToSay.Domain.Common;

namespace YouHaveToSay.Domain.Entities;

public class User : AuditableEntity
{
    public Guid Id { get; set; }

    public string FirebaseUserId { get; set; } = null!;

    public string Email { get; set; } = null!;

    public ICollection<Vote> Votes { get; set; } = new List<Vote>();
}
