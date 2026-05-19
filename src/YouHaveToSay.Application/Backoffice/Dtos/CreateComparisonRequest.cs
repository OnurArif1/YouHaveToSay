namespace YouHaveToSay.Application.Backoffice.Dtos;

public class CreateComparisonRequest
{
    public string TitleTr { get; set; } = null!;

    public string TitleEn { get; set; } = null!;

    public string Category { get; set; } = null!;

    public bool IsActive { get; set; } = true;

    public ComparisonOptionInput LeftOption { get; set; } = null!;

    public ComparisonOptionInput RightOption { get; set; } = null!;
}
