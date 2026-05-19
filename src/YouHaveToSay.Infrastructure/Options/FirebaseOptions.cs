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

    /// <summary>
    /// Yerel Firebase Auth Emulator (geliştirme).
    /// </summary>
    public bool UseEmulator { get; set; }

    public string EmulatorHost { get; set; } = "localhost:9099";
}
