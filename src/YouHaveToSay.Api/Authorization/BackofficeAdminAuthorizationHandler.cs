using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using YouHaveToSay.Application.Backoffice.Interfaces;

namespace YouHaveToSay.Api.Authorization;

public class BackofficeAdminAuthorizationHandler(IBackofficeAuthorizationService backofficeAuth)
    : AuthorizationHandler<BackofficeAdminRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        BackofficeAdminRequirement requirement)
    {
        if (context.User.Identity?.IsAuthenticated != true)
        {
            return Task.CompletedTask;
        }

        var email = context.User.FindFirstValue(ClaimTypes.Email);
        if (backofficeAuth.IsAdminEmail(email))
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}
