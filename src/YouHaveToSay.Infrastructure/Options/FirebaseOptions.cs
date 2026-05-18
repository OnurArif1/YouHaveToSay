namespace YouHaveToSay.Infrastructure.Options;

public class FirebaseOptions
{
    public const string SectionName = "Firebase";

    /// <summary>
    /// true: Firebase Admin SDK ile doğrulama. false: geliştirme modu (dev:uid:email token).
    /// </summary>
    public bool Enabled { get; set; }

    public string? ProjectId { get; set; }

    public string? CredentialsPath { get; set; }
}
