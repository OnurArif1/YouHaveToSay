namespace YouHaveToSay.Infrastructure.Options;

public class JwtOptions
{
    public const string SectionName = "Jwt";

    public string Secret { get; set; } = null!;

    public string Issuer { get; set; } = "YouHaveToSay";

    public string Audience { get; set; } = "YouHaveToSay";

    public int ExpirationMinutes { get; set; } = 60;
}
