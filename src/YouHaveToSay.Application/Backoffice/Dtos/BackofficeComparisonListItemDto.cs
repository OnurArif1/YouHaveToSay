namespace YouHaveToSay.Application.Backoffice.Dtos;

public class BackofficeComparisonListItemDto
{
    public Guid Id { get; set; }

    public string TitleTr { get; set; } = null!;

    public string TitleEn { get; set; } = null!;

    public string Category { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public int OptionCount { get; set; }

    public int TotalVotes { get; set; }

    public string LeftOptionText { get; set; } = null!;

    public string RightOptionText { get; set; } = null!;
}
