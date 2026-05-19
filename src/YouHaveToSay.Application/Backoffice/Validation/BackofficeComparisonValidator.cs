using YouHaveToSay.Application.Backoffice.Dtos;
using YouHaveToSay.Application.Common.Exceptions;

namespace YouHaveToSay.Application.Backoffice.Validation;

public static class BackofficeComparisonValidator
{
    private const int MaxCategoryLength = 100;

    public static void ValidateCreate(CreateComparisonRequest request)
    {
        ValidateCommon(
            request.TitleTr,
            request.Category,
            request.LeftOption,
            request.RightOption);
    }

    public static void ValidateUpdate(UpdateComparisonRequest request)
    {
        ValidateCommon(
            request.TitleTr,
            request.Category,
            request.LeftOption,
            request.RightOption);
    }

    private static void ValidateCommon(
        string? titleTr,
        string? category,
        ComparisonOptionInput? leftOption,
        ComparisonOptionInput? rightOption)
    {
        if (string.IsNullOrWhiteSpace(titleTr))
        {
            ThrowValidation("Title is required.");
        }

        if (string.IsNullOrWhiteSpace(category))
        {
            ThrowValidation("Category is required.");
        }

        if (category!.Trim().Length > MaxCategoryLength)
        {
            ThrowValidation($"Category must be at most {MaxCategoryLength} characters.");
        }

        if (leftOption is null || string.IsNullOrWhiteSpace(leftOption.TextTr))
        {
            ThrowValidation("Left option text is required.");
        }

        if (rightOption is null || string.IsNullOrWhiteSpace(rightOption.TextTr))
        {
            ThrowValidation("Right option text is required.");
        }

        ValidateDistinctOptions(leftOption!, rightOption!);
        ValidateImageUrl(leftOption!.ImageUrl);
        ValidateImageUrl(rightOption!.ImageUrl);
    }

    private static void ValidateDistinctOptions(ComparisonOptionInput left, ComparisonOptionInput right)
    {
        if (string.Equals(left.TextTr.Trim(), right.TextTr.Trim(), StringComparison.OrdinalIgnoreCase))
        {
            ThrowValidation("Left and right option text must not be identical.");
        }

        if (!string.IsNullOrWhiteSpace(left.TextEn) &&
            !string.IsNullOrWhiteSpace(right.TextEn) &&
            string.Equals(left.TextEn.Trim(), right.TextEn.Trim(), StringComparison.OrdinalIgnoreCase))
        {
            ThrowValidation("Left and right option English text must not be identical.");
        }
    }

    private static void ValidateImageUrl(string? imageUrl)
    {
        if (string.IsNullOrWhiteSpace(imageUrl))
        {
            return;
        }

        if (!Uri.TryCreate(imageUrl.Trim(), UriKind.Absolute, out var uri) ||
            (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
        {
            ThrowValidation("Image URL must be a valid http or https URL.");
        }
    }

    private static void ThrowValidation(string message) =>
        throw new BadRequestAppException(message, "VALIDATION_ERROR");
}
