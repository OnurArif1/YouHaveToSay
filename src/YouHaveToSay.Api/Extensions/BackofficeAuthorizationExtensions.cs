using Microsoft.AspNetCore.Authorization;
using YouHaveToSay.Api.Authorization;
using YouHaveToSay.Application.Backoffice.Interfaces;
using YouHaveToSay.Infrastructure.Backoffice;
using YouHaveToSay.Infrastructure.Options;

namespace YouHaveToSay.Api.Extensions;

public static class BackofficeAuthorizationExtensions
{
    public static IServiceCollection AddBackofficeAuthorization(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<BackofficeOptions>(configuration.GetSection(BackofficeOptions.SectionName));
        services.AddScoped<IBackofficeAuthorizationService, BackofficeAuthorizationService>();

        services.AddAuthorization(options =>
        {
            options.AddPolicy(
                BackofficeAuthorizationPolicies.AdminOnly,
                policy => policy.Requirements.Add(new BackofficeAdminRequirement()));
        });

        services.AddScoped<IAuthorizationHandler, BackofficeAdminAuthorizationHandler>();

        return services;
    }
}
