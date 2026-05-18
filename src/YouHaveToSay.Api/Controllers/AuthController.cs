using Microsoft.AspNetCore.Mvc;
using YouHaveToSay.Application.Auth.Dtos;
using YouHaveToSay.Application.Auth.Interfaces;

namespace YouHaveToSay.Api.Controllers;

[ApiController]
[Route("api/auth")]
[Produces("application/json")]
public class AuthController(IAuthService authService) : ControllerBase
{
    [HttpPost("register-or-login")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthResponse>> RegisterOrLogin(
        [FromBody] RegisterOrLoginRequest request,
        CancellationToken cancellationToken)
    {
        var response = await authService.RegisterOrLoginAsync(request.FirebaseToken, cancellationToken);
        return Ok(response);
    }
}
