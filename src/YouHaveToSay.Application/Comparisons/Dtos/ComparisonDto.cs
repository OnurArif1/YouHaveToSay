namespace YouHaveToSay.Application.Comparisons.Dtos;

public class ComparisonDto
{
    public Guid Id { get; set; }

    public string TitleTr { get; set; } = null!;

    public string TitleEn { get; set; } = null!;

    public ComparisonOptionDto LeftOption { get; set; } = null!;

    public ComparisonOptionDto RightOption { get; set; } = null!;

    public string Category { get; set; } = string.Empty;

    public bool HasVoted { get; set; }
}
