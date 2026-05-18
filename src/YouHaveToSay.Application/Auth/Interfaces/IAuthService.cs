using YouHaveToSay.Application.Auth.Dtos;

namespace YouHaveToSay.Application.Auth.Interfaces;

public interface IAuthService
{
    Task<AuthResponse> RegisterOrLoginAsync(string firebaseToken, CancellationToken cancellationToken = default);
}
