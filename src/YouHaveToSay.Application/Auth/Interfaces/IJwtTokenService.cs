using YouHaveToSay.Domain.Entities;

namespace YouHaveToSay.Application.Auth.Interfaces;

public interface IJwtTokenService
{
    (string Token, DateTime ExpiresAt) CreateAccessToken(User user);
}
