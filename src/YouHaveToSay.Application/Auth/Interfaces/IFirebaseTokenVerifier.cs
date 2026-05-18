using YouHaveToSay.Application.Auth.Models;

namespace YouHaveToSay.Application.Auth.Interfaces;

public interface IFirebaseTokenVerifier
{
    Task<FirebaseUserInfo> VerifyAsync(string firebaseToken, CancellationToken cancellationToken = default);
}
