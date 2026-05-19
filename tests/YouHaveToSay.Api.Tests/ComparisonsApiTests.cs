using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using YouHaveToSay.Application.Auth.Dtos;
using YouHaveToSay.Application.Comparisons.Dtos;

namespace YouHaveToSay.Api.Tests;

public class ComparisonsApiTests : IClassFixture<CustomWebApplicationFactory>
{
    private readonly HttpClient _client;
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };

    public ComparisonsApiTests(CustomWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetFeed_WithoutToken_ReturnsUnauthorized()
    {
        var response = await _client.GetAsync("/api/comparisons/feed");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task ComparisonFlow_FeedVoteAndExclude_Works()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return;
        }

        var suffix = Guid.NewGuid().ToString("N")[..8];
        var token = await LoginAsync($"dev:cmp-test-{suffix}:cmp@example.com");

        var feed = await GetFeedAsync(token, limit: 5);
        Assert.NotEmpty(feed.Items);
        Assert.Equal(2, CountActiveOptions(feed.Items[0]));

        var comparison = feed.Items[0];
        var selectedId = comparison.LeftOption.Id;

        var voteResult = await VoteComparisonAsync(token, comparison.Id, selectedId);
        Assert.Equal(comparison.Id, voteResult.ComparisonId);
        Assert.Equal(selectedId, voteResult.SelectedOptionId);
        Assert.True(voteResult.TotalVotes >= 1);
        Assert.Equal(100, voteResult.LeftOption.Percentage + voteResult.RightOption.Percentage, 0.01);

        var duplicate = await VoteComparisonRawAsync(token, comparison.Id, selectedId);
        Assert.Equal(HttpStatusCode.Conflict, duplicate.StatusCode);

        var feedAfter = await GetFeedAsync(token, limit: 25);
        Assert.DoesNotContain(feedAfter.Items, c => c.Id == comparison.Id);
    }

    [Fact]
    public async Task Vote_InvalidOption_ReturnsBadRequest()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return;
        }

        var suffix = Guid.NewGuid().ToString("N")[..8];
        var token = await LoginAsync($"dev:cmp-invalid-{suffix}:invalid@example.com");
        var feed = await GetFeedAsync(token, limit: 1);
        if (feed.Items.Count == 0)
        {
            return;
        }

        var response = await VoteComparisonRawAsync(
            token,
            feed.Items[0].Id,
            Guid.NewGuid());

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task GetFeed_RespectsLimit()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return;
        }

        var suffix = Guid.NewGuid().ToString("N")[..8];
        var token = await LoginAsync($"dev:cmp-limit-{suffix}:limit@example.com");
        var feed = await GetFeedAsync(token, limit: 3);
        Assert.True(feed.Items.Count <= 3);
    }

    [Fact]
    public async Task GetNextPoll_StillWorks_AfterComparisonChanges()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return;
        }

        var suffix = Guid.NewGuid().ToString("N")[..8];
        var token = await LoginAsync($"dev:cmp-poll-{suffix}:poll@example.com");

        var response = await _client.SendAsync(
            CreateAuthorizedRequest(HttpMethod.Get, "/api/polls/next", token));

        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    private static int CountActiveOptions(ComparisonDto dto) =>
        dto.LeftOption is not null && dto.RightOption is not null ? 2 : 0;

    private async Task<string> LoginAsync(string firebaseToken)
    {
        var response = await _client.PostAsJsonAsync(
            "/api/auth/register-or-login",
            new RegisterOrLoginRequest { FirebaseToken = firebaseToken });

        response.EnsureSuccessStatusCode();
        var auth = await response.Content.ReadFromJsonAsync<AuthResponse>(JsonOptions);
        Assert.NotNull(auth?.AccessToken);
        return auth!.AccessToken;
    }

    private async Task<ComparisonFeedResponseDto> GetFeedAsync(string accessToken, int limit)
    {
        var response = await _client.SendAsync(
            CreateAuthorizedRequest(HttpMethod.Get, $"/api/comparisons/feed?limit={limit}", accessToken));

        response.EnsureSuccessStatusCode();
        var feed = await response.Content.ReadFromJsonAsync<ComparisonFeedResponseDto>(JsonOptions);
        Assert.NotNull(feed);
        return feed!;
    }

    private async Task<ComparisonVoteResultDto> VoteComparisonAsync(
        string accessToken,
        Guid comparisonId,
        Guid selectedOptionId)
    {
        var response = await VoteComparisonRawAsync(accessToken, comparisonId, selectedOptionId);
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<ComparisonVoteResultDto>(JsonOptions);
        Assert.NotNull(result);
        return result!;
    }

    private Task<HttpResponseMessage> VoteComparisonRawAsync(
        string accessToken,
        Guid comparisonId,
        Guid selectedOptionId) =>
        _client.SendAsync(CreateAuthorizedRequest(
            HttpMethod.Post,
            $"/api/comparisons/{comparisonId}/vote",
            accessToken,
            JsonContent.Create(new ComparisonVoteRequest { SelectedOptionId = selectedOptionId })));

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
}
