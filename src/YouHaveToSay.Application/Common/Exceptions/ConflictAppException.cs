namespace YouHaveToSay.Application.Common.Exceptions;

public class ConflictAppException(string message, string code = "CONFLICT")
    : AppException(message, code);
