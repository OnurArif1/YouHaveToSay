using Microsoft.EntityFrameworkCore;
using YouHaveToSay.Application.Auth.Dtos;
using YouHaveToSay.Application.Auth.Interfaces;
using YouHaveToSay.Application.Common.Exceptions;
using YouHaveToSay.Domain.Entities;
using YouHaveToSay.Infrastructure.Persistence;

namespace YouHaveToSay.Infrastructure.Auth;

public class AuthService(
    AppDbContext dbContext,
    IFirebaseTokenVerifier firebaseTokenVerifier,
    IJwtTokenService jwtTokenService) : IAuthService
{
    public async Task<AuthResponse> RegisterOrLoginAsync(
        string firebaseToken,
        CancellationToken cancellationToken = default)
    {
        var firebaseUser = await firebaseTokenVerifier.VerifyAsync(firebaseToken, cancellationToken);

        var user = await dbContext.Users
            .FirstOrDefaultAsync(u => u.FirebaseUserId == firebaseUser.FirebaseUserId, cancellationToken);

        if (user is null)
        {
            user = new User
            {
                Id = Guid.NewGuid(),
                FirebaseUserId = firebaseUser.FirebaseUserId,
                Email = firebaseUser.Email
            };

            dbContext.Users.Add(user);

            try
            {
                await dbContext.SaveChangesAsync(cancellationToken);
            }
            catch (DbUpdateException)
            {
                user = await dbContext.Users
                    .FirstOrDefaultAsync(u => u.FirebaseUserId == firebaseUser.FirebaseUserId, cancellationToken);

                if (user is null)
                {
                    throw;
                }
            }
        }
        else if (!user.IsActive)
        {
            throw new UnauthorizedAppException("User account is inactive.");
        }

        var (token, expiresAt) = jwtTokenService.CreateAccessToken(user);

        return new AuthResponse
        {
            AccessToken = token,
            ExpiresAt = expiresAt,
            User = new UserDto
            {
                Id = user.Id,
                Email = user.Email
            }
        };
    }
}
