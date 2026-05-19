using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Options;
using YouHaveToSay.Application.Auth.Interfaces;
using YouHaveToSay.Application.Auth.Models;
using YouHaveToSay.Application.Common.Exceptions;
using YouHaveToSay.Infrastructure;
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

            if (_options.UseEmulator)
            {
                Environment.SetEnvironmentVariable(
                    "FIREBASE_AUTH_EMULATOR_HOST",
                    _options.EmulatorHost);
            }

            var appOptions = new AppOptions
            {
                ProjectId = _options.ProjectId ?? "demo-youhavetosay",
            };

            if (_options.UseEmulator)
            {
                // Admin SDK Credential zorunlu; emülatörde gerçek anahtar gerekmez.
                appOptions.Credential = GoogleCredential.FromAccessToken("owner");
            }
            else if (!string.IsNullOrWhiteSpace(_options.CredentialsPath) &&
                     DependencyInjection.TryResolveCredentialsPath(
                         _options.CredentialsPath, out var credentialsFile))
            {
                appOptions.Credential = GoogleCredential.FromFile(credentialsFile);
            }
            else
            {
                throw new InvalidOperationException(
                    "Firebase production modu için CredentialsPath yapılandırılmalı.");
            }

            FirebaseApp.Create(appOptions);
            _initialized = true;
        }
    }
}
