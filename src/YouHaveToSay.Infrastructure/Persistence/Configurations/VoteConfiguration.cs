using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YouHaveToSay.Domain.Entities;

namespace YouHaveToSay.Infrastructure.Persistence.Configurations;

public class VoteConfiguration : IEntityTypeConfiguration<Vote>
{
    public void Configure(EntityTypeBuilder<Vote> builder)
    {
        builder.ToTable("Votes");

        builder.HasKey(v => v.Id);

        builder.Property(v => v.CreatedAt)
            .IsRequired();

        builder.Property(v => v.IsActive)
            .IsRequired()
            .HasDefaultValue(true);

        builder.HasIndex(v => new { v.UserId, v.PollId })
            .IsUnique();

        builder.HasOne(v => v.SelectedOption)
            .WithMany(o => o.Votes)
            .HasForeignKey(v => v.SelectedOptionId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
