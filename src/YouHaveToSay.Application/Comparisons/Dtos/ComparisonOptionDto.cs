namespace YouHaveToSay.Application.Comparisons.Dtos;

public class ComparisonOptionDto
{
    public Guid Id { get; set; }

    public string TextTr { get; set; } = null!;

    public string TextEn { get; set; } = null!;

    public string? ImageUrl { get; set; }
}
