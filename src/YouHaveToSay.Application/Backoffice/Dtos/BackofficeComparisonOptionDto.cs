namespace YouHaveToSay.Application.Backoffice.Dtos;

public class BackofficeComparisonOptionDto
{
    public Guid Id { get; set; }

    public string TextTr { get; set; } = null!;

    public string TextEn { get; set; } = null!;

    public string? ImageUrl { get; set; }

    public int DisplayOrder { get; set; }
}
