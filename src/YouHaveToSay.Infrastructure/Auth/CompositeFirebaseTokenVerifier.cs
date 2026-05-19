using YouHaveToSay.Application.Auth.Interfaces;
using YouHaveToSay.Application.Auth.Models;

namespace YouHaveToSay.Infrastructure.Auth;

/// <summary>
/// Production Firebase doğrulaması açıkken bile <c>dev:uid:email</c> token'larını kabul eder
/// (backoffice geliştirme girişi ve testler için).
/// </summary>
public class CompositeFirebaseTokenVerifier(
    DevelopmentFirebaseTokenVerifier developmentVerifier,
    FirebaseTokenVerifier firebaseVerifier) : IFirebaseTokenVerifier
{
    private const string DevPrefix = "dev:";

    public Task<FirebaseUserInfo> VerifyAsync(string firebaseToken, CancellationToken cancellationToken = default)
    {
        if (firebaseToken.StartsWith(DevPrefix, StringComparison.Ordinal))
        {
            return developmentVerifier.VerifyAsync(firebaseToken, cancellationToken);
        }

        return firebaseVerifier.VerifyAsync(firebaseToken, cancellationToken);
    }
}
