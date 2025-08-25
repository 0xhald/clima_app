defmodule ClimaWeb.Router do
  use ClimaWeb, :router

  import ClimaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ClimaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Main weather app - accessible to all users (authenticated and anonymous)
  scope "/", ClimaWeb do
    pipe_through :browser

    live_session :public_with_optional_auth,
      on_mount: [{ClimaWeb.UserAuth, :mount_current_scope}] do
      # Open to all users
      live "/", WeatherLive
    end

    get "/home", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", ClimaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:clima, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ClimaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ClimaWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ClimaWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  # Auth pages - redirect if already logged in
  scope "/", ClimaWeb do
    pipe_through [:browser, :redirect_if_authenticated]

    live_session :auth_pages,
      on_mount: [{ClimaWeb.UserAuth, :redirect_if_authenticated}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end
  end

  # Auth actions
  scope "/", ClimaWeb do
    pipe_through [:browser]

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
