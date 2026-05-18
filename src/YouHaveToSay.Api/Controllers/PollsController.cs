using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YouHaveToSay.Application.Polls.Dtos;
using YouHaveToSay.Application.Polls.Interfaces;

namespace YouHaveToSay.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/polls")]
[Produces("application/json")]
public class PollsController(IPollService pollService) : ControllerBase
{
    [HttpGet("next")]
    [ProducesResponseType(typeof(PollDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<PollDto>> GetNext(CancellationToken cancellationToken)
    {
        var poll = await pollService.GetNextPollAsync(cancellationToken);
        return Ok(poll);
    }

    [HttpPost("{id:guid}/vote")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Vote(
        Guid id,
        [FromBody] VoteRequest request,
        CancellationToken cancellationToken)
    {
        await pollService.VoteAsync(id, request.SelectedOptionId, cancellationToken);
        return NoContent();
    }
}
