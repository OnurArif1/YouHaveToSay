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

        if (ShouldUseFirebaseAdminVerifier(firebaseOptions))
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

    private static bool ShouldUseFirebaseAdminVerifier(FirebaseOptions options)
    {
        if (options.UseEmulator)
        {
            return true;
        }

        if (!options.Enabled)
        {
            return false;
        }

        if (string.IsNullOrWhiteSpace(options.CredentialsPath))
        {
            return false;
        }

        return TryResolveCredentialsPath(options.CredentialsPath, out _);
    }

    internal static bool TryResolveCredentialsPath(string path, out string resolvedPath)
    {
        if (Path.IsPathRooted(path) && File.Exists(path))
        {
            resolvedPath = path;
            return true;
        }

        var candidates = new List<string>
        {
            Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, path)),
            Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), path)),
        };

        // dotnet run: bin/Debug/net9.0 → repo kökü (mobile ile aynı seviye)
        var dir = AppContext.BaseDirectory;
        for (var i = 0; i < 8; i++)
        {
            candidates.Add(Path.GetFullPath(Path.Combine(dir, path)));
            var parent = Directory.GetParent(dir);
            if (parent is null)
            {
                break;
            }

            dir = parent.FullName;
        }

        foreach (var candidate in candidates.Distinct())
        {
            if (File.Exists(candidate))
            {
                resolvedPath = candidate;
                return true;
            }
        }

        resolvedPath = string.Empty;
        return false;
    }
}
