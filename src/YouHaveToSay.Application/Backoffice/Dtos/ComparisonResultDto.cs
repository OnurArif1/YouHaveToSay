namespace YouHaveToSay.Application.Backoffice.Dtos;

public class ComparisonResultDto
{
    public Guid ComparisonId { get; set; }

    public string TitleTr { get; set; } = null!;

    public string TitleEn { get; set; } = null!;

    public int TotalVotes { get; set; }

    public IReadOnlyList<ComparisonOptionResultDto> Options { get; set; } = [];
}
