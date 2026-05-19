namespace YouHaveToSay.Application.Comparisons.Dtos;

public class ComparisonFeedResponseDto
{
    public IReadOnlyList<ComparisonDto> Items { get; set; } = Array.Empty<ComparisonDto>();

    public bool HasMore { get; set; }
}
