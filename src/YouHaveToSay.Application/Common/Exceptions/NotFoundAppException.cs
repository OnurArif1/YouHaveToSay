namespace YouHaveToSay.Application.Common.Exceptions;

public class NotFoundAppException(string message, string code = "NOT_FOUND")
    : AppException(message, code);
