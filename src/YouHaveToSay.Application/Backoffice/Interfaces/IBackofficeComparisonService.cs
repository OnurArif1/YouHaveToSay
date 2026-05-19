using YouHaveToSay.Application.Backoffice.Dtos;

namespace YouHaveToSay.Application.Backoffice.Interfaces;

public interface IBackofficeComparisonService
{
    Task<BackofficeDashboardDto> GetDashboardAsync(CancellationToken cancellationToken = default);

    Task<BackofficePagedResponse<BackofficeComparisonListItemDto>> GetComparisonsAsync(
        BackofficeComparisonQuery query,
        CancellationToken cancellationToken = default);

    Task<BackofficeComparisonDetailDto> GetComparisonDetailAsync(
        Guid id,
        CancellationToken cancellationToken = default);

    Task<Guid> CreateComparisonAsync(
        CreateComparisonRequest request,
        CancellationToken cancellationToken = default);

    Task UpdateComparisonAsync(
        Guid id,
        UpdateComparisonRequest request,
        CancellationToken cancellationToken = default);

    Task UpdateComparisonStatusAsync(
        Guid id,
        UpdateComparisonStatusRequest request,
        CancellationToken cancellationToken = default);

    Task<ComparisonResultDto> GetComparisonResultsAsync(
        Guid id,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<string>> GetCategoriesAsync(CancellationToken cancellationToken = default);
}
