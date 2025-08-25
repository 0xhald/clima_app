# AGENTS.md - Clima Phoenix Application

## Build/Test Commands
- `mix setup` - Install deps and setup database
- `mix phx.server` - Start development server
- `mix test` - Run all tests (auto-creates/migrates test DB)
- `mix test test/path/to/specific_test.exs` - Run single test file
- `mix test test/path/to/specific_test.exs:42` - Run test at specific line
- `mix format` - Format code using .formatter.exs rules

## Code Style Guidelines
- Use Elixir formatter (configured in .formatter.exs)
- Import deps: [:ecto, :ecto_sql, :phoenix], plugins: [Phoenix.LiveView.HTMLFormatter]
- File extensions: .ex (modules), .exs (scripts), .heex (templates)
- Module naming: CamelCase with app prefix (ClimaWeb.PageController)
- Function naming: snake_case
- Private functions: prefix with defp
- Use `use ClimaWeb, :controller` for controllers, similar patterns for other contexts

## Error Handling
- Use pattern matching with {:ok, result} and {:error, reason} tuples
- Handle errors at boundaries (controllers, LiveViews)
- Use Ecto changesets for data validation

## Dependencies
- Phoenix ~> 1.8, LiveView, Ecto/PostgreSQL, Tailwind CSS, daisyUI, Heroicons
- Use existing deps before adding new ones - check mix.exs first