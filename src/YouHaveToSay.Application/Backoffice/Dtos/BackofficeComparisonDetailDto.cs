namespace YouHaveToSay.Application.Backoffice.Dtos;

public class BackofficeComparisonDetailDto
{
    public Guid Id { get; set; }

    public string TitleTr { get; set; } = null!;

    public string TitleEn { get; set; } = null!;

    public string Category { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public IReadOnlyList<BackofficeComparisonOptionDto> Options { get; set; } = [];
}
