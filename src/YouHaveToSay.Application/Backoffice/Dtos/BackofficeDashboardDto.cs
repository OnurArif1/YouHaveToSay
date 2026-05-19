namespace YouHaveToSay.Application.Backoffice.Dtos;

public class BackofficeDashboardDto
{
    public int TotalComparisons { get; set; }

    public int ActiveComparisons { get; set; }

    public int InactiveComparisons { get; set; }

    public int TotalVotes { get; set; }

    public int ComparisonsCreatedThisWeek { get; set; }

    public double AverageVotesPerComparison { get; set; }

    public IReadOnlyList<BackofficeComparisonListItemDto> MostVotedComparisons { get; set; } = [];

    public IReadOnlyList<BackofficeComparisonListItemDto> LatestComparisons { get; set; } = [];
}
