using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using YouHaveToSay.Application.Auth.Dtos;
using YouHaveToSay.Application.Backoffice.Dtos;
using YouHaveToSay.Application.Comparisons.Dtos;

namespace YouHaveToSay.Api.Tests;

public class BackofficeApiTests : IClassFixture<CustomWebApplicationFactory>
{
    private readonly HttpClient _client;

    public BackofficeApiTests(CustomWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Dashboard_Admin_ReturnsOk()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return;
        }

        var token = await LoginAsync($"bo-dash-{Guid.NewGuid():N}", "admin@youhavetosay.com");
        var response = await AuthorizedGetAsync("/api/backoffice/dashboard", token);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var dashboard = await response.Content.ReadFromJsonAsync<BackofficeDashboardDto>();
        Assert.NotNull(dashboard);
        Assert.True(dashboard!.TotalComparisons >= 0);
    }

    [Fact]
    public async Task CreateComparison_Admin_CreatesTwoOptions()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return;
        }

        var token = await LoginAsync($"bo-create-{Guid.NewGuid():N}", "admin@youhavetosay.com");
        var request = new CreateComparisonRequest
        {
            TitleTr = $"Test {Guid.NewGuid():N}"[..20],
            TitleEn = "Test EN",
            Category = "test",
            IsActive = false,
            LeftOption = new ComparisonOptionInput { TextTr = "Sol A", TextEn = "Left A" },
            RightOption = new ComparisonOptionInput { TextTr = "Sağ B", TextEn = "Right B" }
        };

        var createResponse = await _client.SendAsync(CreateAuthorizedRequest(
            HttpMethod.Post,
            "/api/backoffice/comparisons",
            token,
            JsonContent.Create(request)));

        Assert.Equal(HttpStatusCode.Created, createResponse.StatusCode);

        var created = await createResponse.Content.ReadFromJsonAsync<CreatedResponse>();
        Assert.NotNull(created?.Id);

        var detailResponse = await AuthorizedGetAsync($"/api/backoffice/comparisons/{created!.Id}", token);
        var detail = await detailResponse.Content.ReadFromJsonAsync<BackofficeComparisonDetailDto>();
        Assert.NotNull(detail);
        Assert.Equal(2, detail!.Options.Count);
    }

    [Fact]
    public async Task Results_Percentages_SumTo100_WhenVotesExist()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return;
        }

        var adminToken = await LoginAsync($"bo-res-admin-{Guid.NewGuid():N}", "admin@youhavetosay.com");
        var userToken = await LoginAsync($"bo-res-user-{Guid.NewGuid():N}", "voter@example.com");

        var request = new CreateComparisonRequest
        {
            TitleTr = $"Result {Guid.NewGuid():N}"[..24],
            TitleEn = "Result EN",
            Category = "test",
            IsActive = true,
            LeftOption = new ComparisonOptionInput { TextTr = "Alpha", TextEn = "Alpha" },
            RightOption = new ComparisonOptionInput { TextTr = "Beta", TextEn = "Beta" }
        };

        var createResponse = await _client.SendAsync(CreateAuthorizedRequest(
            HttpMethod.Post,
            "/api/backoffice/comparisons",
            adminToken,
            JsonContent.Create(request)));

        var created = await createResponse.Content.ReadFromJsonAsync<CreatedResponse>();
        Assert.NotNull(created?.Id);

        var detail = await (await AuthorizedGetAsync($"/api/backoffice/comparisons/{created!.Id}", adminToken))
            .Content.ReadFromJsonAsync<BackofficeComparisonDetailDto>();
        Assert.NotNull(detail);
        var leftId = detail!.Options.OrderBy(o => o.DisplayOrder).First().Id;

        var voteResponse = await _client.SendAsync(CreateAuthorizedRequest(
            HttpMethod.Post,
            $"/api/comparisons/{created.Id}/vote",
            userToken,
            JsonContent.Create(new ComparisonVoteRequest { SelectedOptionId = leftId })));

        Assert.Equal(HttpStatusCode.OK, voteResponse.StatusCode);

        var resultsResponse = await AuthorizedGetAsync($"/api/backoffice/comparisons/{created.Id}/results", adminToken);
        var results = await resultsResponse.Content.ReadFromJsonAsync<ComparisonResultDto>();
        Assert.NotNull(results);
        Assert.True(results!.TotalVotes >= 1);
        Assert.Equal(100, results.Options.Sum(o => o.Percentage), 0.01);
    }

    [Fact]
    public async Task CreateComparison_MissingTitle_ReturnsBadRequest()
    {
        var token = await LoginAsync($"bo-val-{Guid.NewGuid():N}", "admin@youhavetosay.com");
        var request = new CreateComparisonRequest
        {
            TitleTr = "",
            Category = "test",
            LeftOption = new ComparisonOptionInput { TextTr = "A", TextEn = "A" },
            RightOption = new ComparisonOptionInput { TextTr = "B", TextEn = "B" }
        };

        var response = await _client.SendAsync(CreateAuthorizedRequest(
            HttpMethod.Post,
            "/api/backoffice/comparisons",
            token,
            JsonContent.Create(request)));

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    private async Task<string> LoginAsync(string firebaseUserId, string email)
    {
        var firebaseToken = $"dev:{firebaseUserId}:{email}";
        var response = await _client.PostAsJsonAsync(
            "/api/auth/register-or-login",
            new RegisterOrLoginRequest { FirebaseToken = firebaseToken });

        response.EnsureSuccessStatusCode();
        var auth = await response.Content.ReadFromJsonAsync<AuthResponse>();
        return auth!.AccessToken;
    }

    private Task<HttpResponseMessage> AuthorizedGetAsync(string url, string token)
    {
        return _client.SendAsync(CreateAuthorizedRequest(HttpMethod.Get, url, token));
    }

    private static HttpRequestMessage CreateAuthorizedRequest(
        HttpMethod method,
        string url,
        string accessToken,
        HttpContent? content = null)
    {
        var request = new HttpRequestMessage(method, url) { Content = content };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        return request;
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

    private sealed class CreatedResponse
    {
        public Guid Id { get; set; }
    }
}
