using YouHaveToSay.Application.Auth.Interfaces;
using YouHaveToSay.Application.Auth.Models;
using YouHaveToSay.Application.Common.Exceptions;

namespace YouHaveToSay.Infrastructure.Auth;

/// <summary>
/// Geliştirme/test için: token formatı dev:{firebaseUserId}:{email}
/// </summary>
public class DevelopmentFirebaseTokenVerifier : IFirebaseTokenVerifier
{
    private const string Prefix = "dev:";

    public Task<FirebaseUserInfo> VerifyAsync(string firebaseToken, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(firebaseToken) || !firebaseToken.StartsWith(Prefix, StringComparison.Ordinal))
        {
            throw new UnauthorizedAppException(
                "Development mode: use token format dev:{firebaseUserId}:{email}");
        }

        var parts = firebaseToken[Prefix.Length..].Split(':', 2);
        if (parts.Length != 2 || string.IsNullOrWhiteSpace(parts[0]) || string.IsNullOrWhiteSpace(parts[1]))
        {
            throw new UnauthorizedAppException("Invalid development token format.");
        }

        return Task.FromResult(new FirebaseUserInfo(parts[0], parts[1]));
    }
}
