namespace YouHaveToSay.Application.Common.Exceptions;

public class ForbiddenAppException(string message = "Forbidden.", string code = "FORBIDDEN")
    : AppException(message, code);
