using System.ComponentModel.DataAnnotations;

namespace YouHaveToSay.Application.Polls.Dtos;

public class VoteRequest
{
    [Required]
    public Guid SelectedOptionId { get; set; }
}
