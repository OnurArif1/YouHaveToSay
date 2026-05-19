namespace YouHaveToSay.Application.Backoffice.Dtos;

public class BackofficeComparisonQuery
{
    public int Page { get; set; } = 1;

    public int PageSize { get; set; } = 20;

    public string? Search { get; set; }

    public string? Category { get; set; }

    public bool? IsActive { get; set; }

    public string SortBy { get; set; } = "createdAt";

    public string SortDirection { get; set; } = "desc";
}
