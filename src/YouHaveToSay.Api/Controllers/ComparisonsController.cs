using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YouHaveToSay.Application.Comparisons.Dtos;
using YouHaveToSay.Application.Comparisons.Interfaces;

namespace YouHaveToSay.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/comparisons")]
[Produces("application/json")]
public class ComparisonsController(IComparisonService comparisonService) : ControllerBase
{
    [HttpGet("feed")]
    [ProducesResponseType(typeof(ComparisonFeedResponseDto), StatusCodes.Status200OK)]
    public async Task<ActionResult<ComparisonFeedResponseDto>> GetFeed(
        [FromQuery] int limit = 10,
        CancellationToken cancellationToken = default)
    {
        var feed = await comparisonService.GetFeedAsync(limit, cancellationToken);
        return Ok(feed);
    }

    [HttpGet("voted")]
    [ProducesResponseType(typeof(VotedComparisonsResponseDto), StatusCodes.Status200OK)]
    public async Task<ActionResult<VotedComparisonsResponseDto>> GetVotedHistory(
        [FromQuery] int limit = 50,
        CancellationToken cancellationToken = default)
    {
        var history = await comparisonService.GetVotedHistoryAsync(limit, cancellationToken);
        return Ok(history);
    }

    [HttpPost("{id:guid}/vote")]
    [ProducesResponseType(typeof(ComparisonVoteResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<ActionResult<ComparisonVoteResultDto>> Vote(
        Guid id,
        [FromBody] ComparisonVoteRequest request,
        CancellationToken cancellationToken = default)
    {
        var result = await comparisonService.VoteAsync(id, request.SelectedOptionId, cancellationToken);
        return Ok(result);
    }
}
