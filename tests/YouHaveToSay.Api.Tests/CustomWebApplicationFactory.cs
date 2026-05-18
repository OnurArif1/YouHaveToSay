using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;

namespace YouHaveToSay.Api.Tests;

public class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development");

        builder.ConfigureAppConfiguration((_, config) =>
        {
            config.AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Firebase:Enabled"] = "false",
                ["Jwt:Secret"] = "YouHaveToSay_Test_Secret_Key_Min32Chars!!",
                ["Jwt:Issuer"] = "YouHaveToSay",
                ["Jwt:Audience"] = "YouHaveToSay",
                ["Jwt:ExpirationMinutes"] = "60",
                ["ConnectionStrings:DefaultConnection"] =
                    "Host=localhost;Port=5432;Database=YouHaveToSay;Username=postgres;Password=postgres"
            });
        });
    }
}
