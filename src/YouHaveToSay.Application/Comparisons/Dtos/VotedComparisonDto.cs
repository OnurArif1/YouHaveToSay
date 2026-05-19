namespace YouHaveToSay.Application.Comparisons.Dtos;

public class VotedComparisonsResponseDto
{
    public IReadOnlyList<VotedComparisonDto> Items { get; set; } = Array.Empty<VotedComparisonDto>();
}

public class VotedComparisonDto
{
    public Guid Id { get; set; }

    public string TitleTr { get; set; } = null!;

    public string TitleEn { get; set; } = null!;

    public ComparisonOptionDto LeftOption { get; set; } = null!;

    public ComparisonOptionDto RightOption { get; set; } = null!;

    public string Category { get; set; } = string.Empty;

    public Guid SelectedOptionId { get; set; }

    public DateTime VotedAt { get; set; }

    public int TotalVotes { get; set; }

    public ComparisonVoteOptionResultDto LeftResult { get; set; } = null!;

    public ComparisonVoteOptionResultDto RightResult { get; set; } = null!;
}
