using Microsoft.Extensions.Options;
using YouHaveToSay.Application.Backoffice.Interfaces;
using YouHaveToSay.Infrastructure.Options;

namespace YouHaveToSay.Infrastructure.Backoffice;

public class BackofficeAuthorizationService(IOptions<BackofficeOptions> options) : IBackofficeAuthorizationService
{
    private readonly HashSet<string> _adminEmails = options.Value.AdminEmails
        .Where(e => !string.IsNullOrWhiteSpace(e))
        .Select(e => e.Trim())
        .ToHashSet(StringComparer.OrdinalIgnoreCase);

    public bool IsAdminEmail(string? email) =>
        !string.IsNullOrWhiteSpace(email) && _adminEmails.Contains(email.Trim());
}
