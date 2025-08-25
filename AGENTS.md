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

<!-- phoenix-gen-auth-start -->
## Authentication

- **Always** handle authentication flow at the router level with proper redirects
- **Always** be mindful of where to place routes. `phx.gen.auth` creates multiple router plugs and `live_session` scopes:
  - A plug `:fetch_current_user` that is included in the default browser pipeline
  - A plug `:require_authenticated_user` that redirects to the log in page when the user is not authenticated
  - A `live_session :current_user` scope - For routes that need the current user but don't require authentication, similar to `:fetch_current_user`
  - A `live_session :require_authenticated_user` scope - For routes that require authentication, similar to the plug with the same name
  - In both cases, a `@current_scope` is assigned to the Plug connection and LiveView socket
  - A plug `redirect_if_user_is_authenticated` that redirects to a default path in case the user is authenticated - useful for a registration page that should only be shown to unauthenticated users
- **Always let the user know in which router scopes, `live_session`, and pipeline you are placing the route, AND SAY WHY**
- `phx.gen.auth` assigns the `current_scope` assign - it **does not assign a `current_user` assign**.
- To derive/access `current_user`, **always use the `current_scope.user` assign**, never use **`@current_user`** in templates or LiveViews
- **Never** duplicate `live_session` names. A `live_session :current_user` can only be defined __once__ in the router, so all routes for the `live_session :current_user`  must be grouped in a single block
- Anytime you hit `current_scope` errors or the logged in session isn't displaying the right content, **always double check the router and ensure you are using the correct plug and `live_session` as described below**

### Routes that require authentication

LiveViews that require login should **always be placed inside the __existing__ `live_session :require_authenticated_user` block**:

    scope "/", AppWeb do
      pipe_through [:browser, :require_authenticated_user]

      live_session :require_authenticated_user,
        on_mount: [{ClimaWeb.UserAuth, :require_authenticated}] do
        # phx.gen.auth generated routes
        live "/users/settings", UserLive.Settings, :edit
        live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
        # our own routes that require logged in user
        live "/", MyLiveThatRequiresAuth, :index
      end
    end

Controller routes must be placed in a scope that sets the `:require_authenticated_user` plug:

    scope "/", AppWeb do
      pipe_through [:browser, :require_authenticated_user]

      get "/", MyControllerThatRequiresAuth, :index
    end

### Routes that work with or without authentication

LiveViews that can work with or without authentication, **always use the __existing__ `:current_user` scope**, ie:

    scope "/", MyAppWeb do
      pipe_through [:browser]

      live_session :current_user,
        on_mount: [{ClimaWeb.UserAuth, :mount_current_scope}] do
        # our own routes that work with or without authentication
        live "/", PublicLive
      end
    end

Controllers automatically have the `current_scope` available if they use the `:browser` pipeline.

<!-- phoenix-gen-auth-end -->