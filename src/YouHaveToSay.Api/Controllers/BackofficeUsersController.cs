using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YouHaveToSay.Api.Authorization;
using YouHaveToSay.Application.Backoffice.Dtos;
using YouHaveToSay.Application.Backoffice.Interfaces;

namespace YouHaveToSay.Api.Controllers;

[ApiController]
[Authorize(Policy = BackofficeAuthorizationPolicies.AdminOnly)]
[Route("api/backoffice/users")]
[Produces("application/json")]
public class BackofficeUsersController(IBackofficeUsersService usersService) : ControllerBase
{
    [HttpGet("summary")]
    [ProducesResponseType(typeof(BackofficeUsersSummaryDto), StatusCodes.Status200OK)]
    public async Task<ActionResult<BackofficeUsersSummaryDto>> GetSummary(CancellationToken cancellationToken)
    {
        var summary = await usersService.GetSummaryAsync(cancellationToken);
        return Ok(summary);
    }
}
