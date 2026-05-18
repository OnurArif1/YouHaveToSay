namespace YouHaveToSay.Application.Auth.Dtos;

public class AuthResponse
{
    public string AccessToken { get; set; } = null!;

    public DateTime ExpiresAt { get; set; }

    public UserDto User { get; set; } = null!;
}

public class UserDto
{
    public Guid Id { get; set; }

    public string Email { get; set; } = null!;
}
