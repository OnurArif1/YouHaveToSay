using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using YouHaveToSay.Application.Auth.Dtos;
using YouHaveToSay.Application.Polls.Dtos;

namespace YouHaveToSay.Api.Tests;

public class PollsApiTests : IClassFixture<CustomWebApplicationFactory>
{
    private readonly HttpClient _client;
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };

    public PollsApiTests(CustomWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task FullPollFlow_RegisterVoteAndGetNext_Works()
    {
        if (!await IsPostgresAvailableAsync())
        {
            return;
        }

        var suffix = Guid.NewGuid().ToString("N")[..8];
        var token = await LoginAsync($"dev:api-test-{suffix}:apitest@example.com");

        var poll = await GetNextPollAsync(token);
        Assert.NotEmpty(poll.Options);

        var voteResponse = await VoteAsync(token, poll.Id, poll.Options[0].Id);
        Assert.Equal(HttpStatusCode.NoContent, voteResponse.StatusCode);

        var duplicateVote = await VoteAsync(token, poll.Id, poll.Options[0].Id);
        Assert.Equal(HttpStatusCode.Conflict, duplicateVote.StatusCode);

        var errorBody = await duplicateVote.Content.ReadAsStringAsync();
        Assert.Contains("ALREADY_VOTED", errorBody, StringComparison.OrdinalIgnoreCase);

        var nextResponse = await _client.SendAsync(CreateAuthorizedRequest(HttpMethod.Get, "/api/polls/next", token));
        if (nextResponse.StatusCode == HttpStatusCode.NotFound)
        {
            var noMore = await nextResponse.Content.ReadAsStringAsync();
            Assert.Contains("NO_MORE_POLLS", noMore, StringComparison.OrdinalIgnoreCase);
        }
        else
        {
            nextResponse.EnsureSuccessStatusCode();
            var nextPoll = await nextResponse.Content.ReadFromJsonAsync<PollDto>(JsonOptions);
            Assert.NotNull(nextPoll);
            Assert.NotEqual(poll.Id, nextPoll!.Id);
        }
    }

    [Fact]
    public async Task GetNextPoll_WithoutToken_ReturnsUnauthorized()
    {
        var response = await _client.GetAsync("/api/polls/next");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

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

    private async Task<PollDto> GetNextPollAsync(string accessToken)
    {
        var response = await _client.SendAsync(
            CreateAuthorizedRequest(HttpMethod.Get, "/api/polls/next", accessToken));

        response.EnsureSuccessStatusCode();
        var poll = await response.Content.ReadFromJsonAsync<PollDto>(JsonOptions);
        Assert.NotNull(poll);
        return poll!;
    }

    private Task<HttpResponseMessage> VoteAsync(string accessToken, Guid pollId, Guid optionId) =>
        _client.SendAsync(CreateAuthorizedRequest(
            HttpMethod.Post,
            $"/api/polls/{pollId}/vote",
            accessToken,
            JsonContent.Create(new VoteRequest { SelectedOptionId = optionId })));

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
