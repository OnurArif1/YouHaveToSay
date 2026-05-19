namespace YouHaveToSay.Application.Comparisons.Dtos;

public class ComparisonVoteResultDto
{
    public Guid ComparisonId { get; set; }

    public Guid SelectedOptionId { get; set; }

    public int TotalVotes { get; set; }

    public ComparisonVoteOptionResultDto LeftOption { get; set; } = null!;

    public ComparisonVoteOptionResultDto RightOption { get; set; } = null!;
}

public class ComparisonVoteOptionResultDto
{
    public Guid Id { get; set; }

    public int VoteCount { get; set; }

    public double Percentage { get; set; }
}
