using YouHaveToSay.Application.Backoffice.Dtos;

namespace YouHaveToSay.Application.Backoffice.Interfaces;

public interface IBackofficeUsersService
{
    Task<BackofficeUsersSummaryDto> GetSummaryAsync(CancellationToken cancellationToken = default);
}
