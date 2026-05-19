namespace YouHaveToSay.Application.Backoffice.Dtos;

public class ComparisonOptionResultDto
{
    public Guid OptionId { get; set; }

    public string TextTr { get; set; } = null!;

    public string TextEn { get; set; } = null!;

    public int VoteCount { get; set; }

    public double Percentage { get; set; }
}
