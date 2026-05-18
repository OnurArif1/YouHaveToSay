namespace YouHaveToSay.Application.Polls.Dtos;

public class PollDto
{
    public Guid Id { get; set; }

    public string QuestionTr { get; set; } = null!;

    public string QuestionEn { get; set; } = null!;

    public IReadOnlyList<PollOptionDto> Options { get; set; } = Array.Empty<PollOptionDto>();
}

public class PollOptionDto
{
    public Guid Id { get; set; }

    public string OptionTextTr { get; set; } = null!;

    public string OptionTextEn { get; set; } = null!;
}
