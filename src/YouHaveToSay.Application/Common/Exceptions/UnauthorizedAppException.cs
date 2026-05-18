namespace YouHaveToSay.Application.Common.Exceptions;

public class UnauthorizedAppException(string message = "Unauthorized.")
    : AppException(message, "UNAUTHORIZED");
