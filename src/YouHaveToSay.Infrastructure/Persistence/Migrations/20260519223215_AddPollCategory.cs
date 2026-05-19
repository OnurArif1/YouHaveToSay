using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace YouHaveToSay.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddPollCategory : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Category",
                table: "Polls",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Category",
                table: "Polls");
        }
    }
}
