using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using YouHaveToSay.Application.Auth.Interfaces;
using YouHaveToSay.Application.Polls.Interfaces;
using YouHaveToSay.Infrastructure.Auth;
using YouHaveToSay.Infrastructure.Options;
using YouHaveToSay.Infrastructure.Persistence;
using YouHaveToSay.Infrastructure.Polls;

namespace YouHaveToSay.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' is not configured.");

        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(connectionString, npgsql =>
                npgsql.MigrationsAssembly(typeof(AppDbContext).Assembly.FullName)));

        services.Configure<FirebaseOptions>(configuration.GetSection(FirebaseOptions.SectionName));
        services.Configure<JwtOptions>(configuration.GetSection(JwtOptions.SectionName));

        var firebaseOptions = configuration.GetSection(FirebaseOptions.SectionName).Get<FirebaseOptions>()
            ?? new FirebaseOptions();

        if (firebaseOptions.Enabled)
        {
            services.AddSingleton<IFirebaseTokenVerifier, FirebaseTokenVerifier>();
        }
        else
        {
            services.AddSingleton<IFirebaseTokenVerifier, DevelopmentFirebaseTokenVerifier>();
        }

        services.AddScoped<IJwtTokenService, JwtTokenService>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IPollService, PollService>();

        return services;
    }
}
