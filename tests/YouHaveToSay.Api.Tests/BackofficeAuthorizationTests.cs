using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using YouHaveToSay.Application.Auth.Dtos;

namespace YouHaveToSay.Api.Tests;

public class BackofficeAuthorizationTests : IClassFixture<CustomWebApplicationFactory>
{
    private readonly HttpClient _client;

    public BackofficeAuthorizationTests(CustomWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task BackofficePing_WithoutToken_ReturnsUnauthorized()
    {
        var response = await _client.GetAsync("/api/backoffice/ping");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task BackofficePing_NonAdmin_ReturnsForbidden()
    {
        var suffix = Guid.NewGuid().ToString("N")[..8];
        var token = await LoginAsync($"dev:bo-nonadmin-{suffix}:notadmin@example.com");

        var response = await SendAuthorizedGetAsync("/api/backoffice/ping", token);
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task BackofficePing_Admin_ReturnsOk()
    {
        var suffix = Guid.NewGuid().ToString("N")[..8];
        var token = await LoginAsync($"dev:bo-admin-{suffix}:admin@youhavetosay.com");

        var response = await SendAuthorizedGetAsync("/api/backoffice/ping", token);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task MobileFeed_NonAdmin_StillWorks()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return;
        }

        var suffix = Guid.NewGuid().ToString("N")[..8];
        var token = await LoginAsync($"dev:bo-mobile-{suffix}:mobile@example.com");

        var response = await SendAuthorizedGetAsync("/api/comparisons/feed?limit=1", token);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    private async Task<string> LoginAsync(string firebaseToken)
    {
        var response = await _client.PostAsJsonAsync(
            "/api/auth/register-or-login",
            new RegisterOrLoginRequest { FirebaseToken = firebaseToken });

        response.EnsureSuccessStatusCode();
        var auth = await response.Content.ReadFromJsonAsync<AuthResponse>();
        Assert.NotNull(auth?.AccessToken);
        return auth!.AccessToken;
    }

    private Task<HttpResponseMessage> SendAuthorizedGetAsync(string url, string accessToken)
    {
        var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        return _client.SendAsync(request);
    }

    private async Task<bool> IsPostgresAvailableAsync()
    {
        try
        {
            var response = await _client.GetAsync("/health");
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }
}
