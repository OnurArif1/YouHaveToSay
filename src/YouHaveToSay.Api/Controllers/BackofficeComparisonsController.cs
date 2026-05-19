using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YouHaveToSay.Api.Authorization;
using YouHaveToSay.Application.Backoffice.Dtos;
using YouHaveToSay.Application.Backoffice.Interfaces;

namespace YouHaveToSay.Api.Controllers;

[ApiController]
[Authorize(Policy = BackofficeAuthorizationPolicies.AdminOnly)]
[Route("api/backoffice")]
[Produces("application/json")]
public class BackofficeComparisonsController(IBackofficeComparisonService backofficeService) : ControllerBase
{
    [HttpGet("ping")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public IActionResult Ping() => Ok(new { status = "ok" });

    [HttpGet("dashboard")]
    [ProducesResponseType(typeof(BackofficeDashboardDto), StatusCodes.Status200OK)]
    public async Task<ActionResult<BackofficeDashboardDto>> GetDashboard(CancellationToken cancellationToken)
    {
        var dashboard = await backofficeService.GetDashboardAsync(cancellationToken);
        return Ok(dashboard);
    }

    [HttpGet("comparisons")]
    [ProducesResponseType(typeof(BackofficePagedResponse<BackofficeComparisonListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<BackofficePagedResponse<BackofficeComparisonListItemDto>>> GetComparisons(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] string? search = null,
        [FromQuery] string? category = null,
        [FromQuery] bool? isActive = null,
        [FromQuery] string sortBy = "createdAt",
        [FromQuery] string sortDirection = "desc",
        CancellationToken cancellationToken = default)
    {
        var query = new BackofficeComparisonQuery
        {
            Page = page,
            PageSize = pageSize,
            Search = search,
            Category = category,
            IsActive = isActive,
            SortBy = sortBy,
            SortDirection = sortDirection
        };

        var result = await backofficeService.GetComparisonsAsync(query, cancellationToken);
        return Ok(result);
    }

    [HttpGet("comparisons/categories")]
    [ProducesResponseType(typeof(IReadOnlyList<string>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<string>>> GetCategories(CancellationToken cancellationToken)
    {
        var categories = await backofficeService.GetCategoriesAsync(cancellationToken);
        return Ok(categories);
    }

    [HttpPost("comparisons")]
    [ProducesResponseType(typeof(object), StatusCodes.Status201Created)]
    public async Task<ActionResult<object>> CreateComparison(
        [FromBody] CreateComparisonRequest request,
        CancellationToken cancellationToken)
    {
        var id = await backofficeService.CreateComparisonAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetComparisonDetail), new { id }, new { id });
    }

    [HttpGet("comparisons/{id:guid}")]
    [ProducesResponseType(typeof(BackofficeComparisonDetailDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<BackofficeComparisonDetailDto>> GetComparisonDetail(
        Guid id,
        CancellationToken cancellationToken)
    {
        var detail = await backofficeService.GetComparisonDetailAsync(id, cancellationToken);
        return Ok(detail);
    }

    [HttpPut("comparisons/{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateComparison(
        Guid id,
        [FromBody] UpdateComparisonRequest request,
        CancellationToken cancellationToken)
    {
        await backofficeService.UpdateComparisonAsync(id, request, cancellationToken);
        return NoContent();
    }

    [HttpPatch("comparisons/{id:guid}/status")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateComparisonStatus(
        Guid id,
        [FromBody] UpdateComparisonStatusRequest request,
        CancellationToken cancellationToken)
    {
        await backofficeService.UpdateComparisonStatusAsync(id, request, cancellationToken);
        return NoContent();
    }

    [HttpGet("comparisons/{id:guid}/results")]
    [ProducesResponseType(typeof(ComparisonResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ComparisonResultDto>> GetComparisonResults(
        Guid id,
        CancellationToken cancellationToken)
    {
        var results = await backofficeService.GetComparisonResultsAsync(id, cancellationToken);
        return Ok(results);
    }
}
