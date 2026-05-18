namespace YouHaveToSay.Application.Common.Exceptions;

public class BadRequestAppException(string message, string code = "BAD_REQUEST")
    : AppException(message, code);
