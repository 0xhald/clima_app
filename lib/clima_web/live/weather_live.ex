defmodule ClimaWeb.WeatherLive do
  use ClimaWeb, :live_view

  alias Clima.{Favorites, WeatherService}

  @impl true
  def mount(_params, _session, socket) do
    favorite_cities = Favorites.list_favorite_cities()

    socket =
      socket
      |> assign(:favorite_cities, favorite_cities)
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
    city_params = %{
      "name" => params["name"],
      "country" => params["country"],
      "state" => params["state"],
      "lat" => String.to_float(params["lat"]),
      "lon" => String.to_float(params["lon"])
    }

    case Favorites.create_favorite_city(city_params) do
      {:ok, _favorite_city} ->
        favorite_cities = Favorites.list_favorite_cities()

        socket =
          socket
          |> assign(:favorite_cities, favorite_cities)
          |> assign(:search_results, [])
          |> assign(:search_query, "")
          |> put_flash(:info, "City added to favorites!")

        {:noreply, socket}

      {:error, changeset} ->
        error_msg =
          case changeset.errors do
            [lat: {"has already been taken", _}] -> "City already in favorites"
            _ -> "Could not add city to favorites"
          end

        {:noreply, put_flash(socket, :error, error_msg)}
    end
  end

  @impl true
  def handle_event("remove_from_favorites", %{"id" => id}, socket) do
    IO.puts("Removing city with ID: #{id}")
    city = Favorites.get_favorite_city!(id)
    {:ok, _} = Favorites.delete_favorite_city(city)

    favorite_cities = Favorites.list_favorite_cities()

    socket =
      socket
      |> assign(:favorite_cities, favorite_cities)
      |> assign(:selected_city, nil)
      |> assign(:current_weather, nil)
      |> assign(:forecast_data, nil)
      |> put_flash(:info, "City removed from favorites")

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_city", %{"id" => id}, socket) do
    city = Favorites.get_favorite_city!(id)
    send(self(), {:load_weather, city})

    {:noreply, assign(socket, selected_city: city, loading_weather: true)}
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

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%I:%M %p")
  end

  defp format_date(date) do
    Calendar.strftime(date, "%a, %b %d")
  end
end
