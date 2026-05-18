namespace YouHaveToSay.Domain.Common;

public abstract class AuditableEntity
{
    public DateTime CreatedAt { get; set; }

    public bool IsActive { get; set; } = true;
}
