defmodule ClimaWeb.UserLive.Registration do
  use ClimaWeb, :live_view

  alias Clima.Accounts
  alias Clima.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>
            Register for an account
            <:subtitle>
              Already registered?
              <.link navigate={~p"/users/log-in"} class="font-semibold text-brand hover:underline">
                Log in
              </.link>
              to your account now.
            </:subtitle>
          </.header>
        </div>

        <%= if @favorite_count > 0 do %>
          <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
            <div class="flex items-center">
              <.icon name="hero-information-circle" class="h-5 w-5 text-blue-600 mr-2" />
              <div class="text-sm text-blue-800">
                <p class="font-medium">Save your session data!</p>
                <p>You have {@favorite_count} favorite cities in this session.
                  Creating an account will save them permanently to your profile.</p>
              </div>
            </div>
          </div>
        <% end %>

        <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
          <.input
            field={@form[:email]}
            type="email"
            label="Email"
            autocomplete="username"
            required
            phx-mounted={JS.focus()}
          />

          <.button phx-disable-with="Creating account..." class="btn btn-primary w-full">
            Create an account
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: ClimaWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, session, socket) do
    changeset = Accounts.change_user_email(%User{}, %{}, validate_unique: false)
    session_favorites = Map.get(session, "favorite_cities", [])
    favorite_count = length(session_favorites)

    socket =
      socket
      |> assign_form(changeset)
      |> assign(:session_favorites, session_favorites)
      |> assign(:favorite_count, favorite_count)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    session_favorites = socket.assigns.session_favorites

    case Accounts.register_user_and_migrate_favorites(user_params, session_favorites) do
      {:ok, %{user: user, migrate_favorites: migrated}} ->
        # Log the user in immediately (no email confirmation)
        conn = Phoenix.LiveView.get_connect_info(socket, :conn)
        conn = ClimaWeb.UserAuth.log_in_user(conn, user)

        success_message =
          build_success_message(user.email, length(migrated), socket.assigns.favorite_count)

        socket =
          socket
          |> put_flash(:info, success_message)
          |> clear_session_favorites()
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, :user, %Ecto.Changeset{} = changeset, _} ->
        {:noreply, assign_form(socket, changeset)}

      {:error, _operation, reason, _changes} ->
        {:noreply, put_flash(socket, :error, "Registration failed: #{inspect(reason)}")}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_email(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end

  defp build_success_message(email, migrated_count, session_count) do
    base_message = "Welcome to Clima Weather, #{email}! You're now logged in."
    
    case {migrated_count, session_count} do
      {0, 0} -> base_message
      {n, n} when n > 0 -> "#{base_message} All #{n} of your session favorites have been saved to your account!"
      {m, s} when m < s -> "#{base_message} #{m} of your #{s} session favorites have been saved (duplicates skipped)."
      _ -> base_message
    end
  end
  
  defp clear_session_favorites(socket) do
    Phoenix.LiveView.delete_session(socket, "favorite_cities")
  end
  end
end
