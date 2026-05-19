namespace YouHaveToSay.Application.Backoffice.Interfaces;

public interface IBackofficeAuthorizationService
{
    bool IsAdminEmail(string? email);
}
