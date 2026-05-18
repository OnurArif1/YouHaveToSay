using System.ComponentModel.DataAnnotations;

namespace YouHaveToSay.Application.Auth.Dtos;

public class RegisterOrLoginRequest
{
    [Required]
    public string FirebaseToken { get; set; } = null!;
}
