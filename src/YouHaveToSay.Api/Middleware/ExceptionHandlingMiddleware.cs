using System.Net;
using System.Text.Json;
using YouHaveToSay.Application.Common.Exceptions;

namespace YouHaveToSay.Api.Middleware;

public class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (AppException ex)
        {
            logger.LogWarning(ex, "Application error: {Code}", ex.Code);
            await WriteErrorAsync(context, MapStatusCode(ex), ex.Code, ex.Message);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled exception");
            await WriteErrorAsync(context, HttpStatusCode.InternalServerError, "INTERNAL_ERROR", "An unexpected error occurred.");
        }
    }

    private static HttpStatusCode MapStatusCode(AppException ex) => ex switch
    {
        UnauthorizedAppException => HttpStatusCode.Unauthorized,
        NotFoundAppException => HttpStatusCode.NotFound,
        ConflictAppException => HttpStatusCode.Conflict,
        BadRequestAppException => HttpStatusCode.BadRequest,
        _ => HttpStatusCode.BadRequest
    };

    private static async Task WriteErrorAsync(HttpContext context, HttpStatusCode status, string code, string message)
    {
        context.Response.StatusCode = (int)status;
        context.Response.ContentType = "application/json";

        var body = new { code, message };
        await context.Response.WriteAsync(JsonSerializer.Serialize(body, JsonOptions));
    }
}
