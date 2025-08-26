defmodule ClimaWeb.WeatherLive do
  use ClimaWeb, :live_view

  alias Clima.{Favorites, WeatherService}

  @impl true
  def mount(_params, session, socket) do
    # Handle both authenticated and anonymous users
    current_user = get_current_user(socket)
    user_or_session = get_user_or_session(socket, session)
    favorite_cities = Favorites.list_favorite_cities(user_or_session)

    socket =
      socket
      |> assign(:favorite_cities, favorite_cities)
      |> assign(:current_user, current_user)
      |> assign(:session, session)
      |> assign(:is_authenticated, !is_nil(current_user))
      |> assign(:search_query, "")
      |> assign(:search_results, [])
      |> assign(:selected_city, nil)
      |> assign(:current_weather, nil)
      |> assign(:forecast_data, nil)
      |> assign(:loading_weather, false)
      |> assign(:loading_search, false)
      |> assign(:error_message, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("search_cities", %{"search" => %{"query" => query}}, socket) do
    if String.length(query) >= 2 do
      send(self(), {:perform_search, query})
      {:noreply, assign(socket, loading_search: true, search_query: query)}
    else
      {:noreply, assign(socket, search_results: [], search_query: query)}
    end
  end

  @impl true
  def handle_event("add_to_favorites", params, socket) do
    user_or_session = get_user_or_session(socket)
    city_params = format_city_params(params)

    case Favorites.create_favorite_city(city_params, user_or_session) do
      {:ok, updated_favorites} ->
        socket =
          socket
          |> assign(:favorite_cities, updated_favorites)
          |> assign(:search_results, [])
          |> assign(:search_query, "")
          |> maybe_update_session_favorites(updated_favorites)
          |> put_flash(:info, get_success_message(socket.assigns.is_authenticated))

        {:noreply, socket}

      {:error, :already_exists} ->
        {:noreply, put_flash(socket, :error, "City already in favorites")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not add city to favorites")}
    end
  end

  @impl true
  def handle_event("remove_from_favorites", %{"id" => id}, socket) do
    user_or_session = get_user_or_session(socket)

    case Favorites.delete_favorite_city(id, user_or_session) do
      {:ok, updated_favorites} ->
        socket =
          socket
          |> assign(:favorite_cities, updated_favorites)
          |> assign(:selected_city, nil)
          |> assign(:current_weather, nil)
          |> assign(:forecast_data, nil)
          |> maybe_update_session_favorites(updated_favorites)
          |> put_flash(:info, "City removed from favorites")

        {:noreply, socket}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "City not found in favorites")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not remove city from favorites")}
    end
  end

  @impl true
  def handle_event("select_city", %{"id" => id}, socket) do
    case find_city_by_id(id, socket.assigns.favorite_cities) do
      nil ->
        {:noreply, put_flash(socket, :error, "City not found")}

      city ->
        send(self(), {:load_weather, city})
        {:noreply, assign(socket, selected_city: city, loading_weather: true)}
    end
  end

  @impl true
  def handle_info({:perform_search, query}, socket) do
    case WeatherService.search_cities(query) do
      {:ok, cities} ->
        {:noreply, assign(socket, search_results: cities, loading_search: false)}

      {:error, _reason} ->
        socket =
          socket
          |> assign(loading_search: false)
          |> put_flash(:error, "Error searching cities. Please try again.")

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:load_weather, city}, socket) do
    with {:ok, current_weather} <- WeatherService.get_current_weather(city.lat, city.lon),
         {:ok, forecast_data} <- WeatherService.get_forecast(city.lat, city.lon) do
      socket =
        socket
        |> assign(:current_weather, current_weather)
        |> assign(:forecast_data, forecast_data)
        |> assign(:loading_weather, false)
        |> assign(:error_message, nil)

      {:noreply, socket}
    else
      {:error, reason} ->
        socket =
          socket
          |> assign(:loading_weather, false)
          |> assign(:error_message, "Error loading weather data: #{reason}")

        {:noreply, socket}
    end
  end

  # Helper functions for dual-mode operation

  defp get_current_user(socket) do
    case socket.assigns do
      %{current_scope: %{user: user}} when not is_nil(user) -> user
      _ -> nil
    end
  end

  defp get_user_or_session(socket, session \\ nil) do
    case get_current_user(socket) do
      nil -> session || socket.assigns[:session] || %{}
      user -> user
    end
  end

  defp format_city_params(params) do
    %{
      name: params["name"],
      country: params["country"],
      state: params["state"],
      lat: String.to_float(params["lat"]),
      lon: String.to_float(params["lon"]),
      openweather_id: params["openweather_id"]
    }
  end

  defp get_success_message(true), do: "City saved to your account!"
  defp get_success_message(false), do: "City added to session (register to save permanently)"

  defp maybe_update_session_favorites(socket, favorites) do
    if socket.assigns.is_authenticated do
      # DB handles persistence
      socket
    else
      # Update session for anonymous users
      session_data =
        Enum.map(favorites, fn city ->
          %{
            "name" => city.name,
            "country" => city.country,
            "state" => city.state,
            "lat" => city.lat,
            "lon" => city.lon,
            "openweather_id" => city.openweather_id
          }
        end)

      # For anonymous users, we can't modify session in LiveView
      # The session will be updated through form submissions
      socket
    end
  end

  defp find_city_by_id(id, favorite_cities) do
    Enum.find(favorite_cities, fn city ->
      to_string(city.id) == to_string(id)
    end)
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%I:%M %p")
  end

  defp format_date(date) do
    Calendar.strftime(date, "%a, %b %d")
  end
end
