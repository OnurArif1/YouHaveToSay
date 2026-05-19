namespace YouHaveToSay.Application.Backoffice.Dtos;

public class BackofficeUsersSummaryDto
{
    public int TotalUsers { get; set; }

    public int TotalVoters { get; set; }

    public int TotalVotes { get; set; }

    public double AverageVotesPerUser { get; set; }

    public int MostActiveVotersCount { get; set; }

    public int NewUsersThisWeek { get; set; }

    public IReadOnlyList<BackofficeUserActivityDto> TopVoters { get; set; } = [];
}

public class BackofficeUserActivityDto
{
    public string Email { get; set; } = null!;

    public int TotalVotes { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? LastVoteAt { get; set; }
}
