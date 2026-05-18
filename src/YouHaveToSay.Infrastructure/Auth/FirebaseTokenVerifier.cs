using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Options;
using YouHaveToSay.Application.Auth.Interfaces;
using YouHaveToSay.Application.Auth.Models;
using YouHaveToSay.Application.Common.Exceptions;
using YouHaveToSay.Infrastructure.Options;

namespace YouHaveToSay.Infrastructure.Auth;

public class FirebaseTokenVerifier(IOptions<FirebaseOptions> options) : IFirebaseTokenVerifier
{
    private readonly FirebaseOptions _options = options.Value;
    private static readonly object InitLock = new();
    private static bool _initialized;

    public async Task<FirebaseUserInfo> VerifyAsync(string firebaseToken, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(firebaseToken))
        {
            throw new UnauthorizedAppException("Firebase token is required.");
        }

        EnsureFirebaseAppInitialized();

        try
        {
            var decoded = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(firebaseToken, cancellationToken);
            var email = decoded.Claims.TryGetValue("email", out var emailValue)
                ? emailValue?.ToString()
                : null;

            if (string.IsNullOrWhiteSpace(email))
            {
                throw new UnauthorizedAppException("Firebase token does not contain an email claim.");
            }

            return new FirebaseUserInfo(decoded.Uid, email);
        }
        catch (FirebaseAuthException)
        {
            throw new UnauthorizedAppException("Invalid Firebase token.");
        }
    }

    private void EnsureFirebaseAppInitialized()
    {
        if (_initialized)
        {
            return;
        }

        lock (InitLock)
        {
            if (_initialized)
            {
                return;
            }

            if (FirebaseApp.DefaultInstance != null)
            {
                _initialized = true;
                return;
            }

            var appOptions = new AppOptions();

            if (!string.IsNullOrWhiteSpace(_options.CredentialsPath))
            {
                appOptions.Credential = GoogleCredential.FromFile(_options.CredentialsPath);
            }

            if (!string.IsNullOrWhiteSpace(_options.ProjectId))
            {
                appOptions.ProjectId = _options.ProjectId;
            }

            FirebaseApp.Create(appOptions);
            _initialized = true;
        }
    }
}
