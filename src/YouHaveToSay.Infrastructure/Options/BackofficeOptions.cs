namespace YouHaveToSay.Infrastructure.Options;

public class BackofficeOptions
{
    public const string SectionName = "Backoffice";

    public List<string> AdminEmails { get; set; } = [];
}
