using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YouHaveToSay.Domain.Entities;

namespace YouHaveToSay.Infrastructure.Persistence.Configurations;

public class PollOptionConfiguration : IEntityTypeConfiguration<PollOption>
{
    public void Configure(EntityTypeBuilder<PollOption> builder)
    {
        builder.ToTable("PollOptions");

        builder.HasKey(o => o.Id);

        builder.Property(o => o.OptionTextTr)
            .IsRequired()
            .HasMaxLength(300);

        builder.Property(o => o.OptionTextEn)
            .IsRequired()
            .HasMaxLength(300);

        builder.Property(o => o.CreatedAt)
            .IsRequired();

        builder.Property(o => o.IsActive)
            .IsRequired()
            .HasDefaultValue(true);

        builder.HasIndex(o => o.PollId);
    }
}
