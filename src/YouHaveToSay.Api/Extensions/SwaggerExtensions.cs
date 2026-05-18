using Microsoft.OpenApi.Models;

namespace YouHaveToSay.Api.Extensions;

public static class SwaggerExtensions
{
    public static IServiceCollection AddYouHaveToSaySwagger(this IServiceCollection services)
    {
        services.AddSwaggerGen(options =>
        {
            options.SwaggerDoc("v1", new OpenApiInfo
            {
                Title = "YouHaveToSay API",
                Version = "v1",
                Description =
                    "Günlük anket/oylama API'si. Önce Firebase token ile giriş yapın, dönen JWT'yi Authorize'a girin."
            });

            options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Name = "Authorization",
                Type = SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                In = ParameterLocation.Header,
                Description = "register-or-login yanıtındaki accessToken. Örnek: Bearer eyJhbG..."
            });

            options.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "Bearer"
                        }
                    },
                    Array.Empty<string>()
                }
            });
        });

        return services;
    }

    public static WebApplication UseYouHaveToSaySwagger(this WebApplication app)
    {
        app.UseSwagger();
        app.UseSwaggerUI(options =>
        {
            options.SwaggerEndpoint("/swagger/v1/swagger.json", "YouHaveToSay API v1");
            options.RoutePrefix = "swagger";
            options.DocumentTitle = "YouHaveToSay API";
        });

        return app;
    }
}
